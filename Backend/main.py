import json
import math
import os
import re
from typing import Any, Dict, List, Optional, Set, Tuple

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI
from pydantic import BaseModel, Field

load_dotenv()

OVERPASS_URLS = [
    "https://overpass-api.de/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
    "https://lz4.overpass-api.de/api/interpreter",
]
NOMINATIM_SEARCH_URL = "https://nominatim.openstreetmap.org/search"
DEFAULT_RADIUS_METERS = 3000
MAX_RADIUS_METERS = 10000
DEFAULT_MAX_RESULTS = 10
MAX_RESULTS = 25

ALLOWED_SERVICE_TAGS: Set[str] = {
    "car_wash",
    "car_cleaning",
    "car_drying",
    "car_polishing",
    "car_detailing",
    "interior_cleaning",
}

SERVICE_KEYWORD_RULES: Dict[str, List[str]] = {
    "car_wash": ["wash", "washing", "car wash"],
    "car_cleaning": ["clean", "cleaning", "deep clean"],
    "car_drying": ["dry", "drying"],
    "car_polishing": ["polish", "polishing", "wax"],
    "car_detailing": ["detail", "detailing"],
    "interior_cleaning": ["interior", "inside cleaning", "vacuum"],
}

OSM_SELECTORS_BY_TAG: Dict[str, List[str]] = {
    "car_wash": ['["amenity"="car_wash"]', '["shop"="car_repair"]["service"~"wash|clean",i]'],
    "car_cleaning": ['["amenity"="car_wash"]', '["name"~"clean|car wash",i]'],
    "car_drying": ['["amenity"="car_wash"]', '["name"~"dry|detailing|car wash",i]'],
    "car_polishing": ['["shop"="car_repair"]["service"~"polish|detailing",i]', '["name"~"polish|detailing|wax",i]'],
    "car_detailing": ['["shop"="car_repair"]["service"~"detail|detailing",i]', '["name"~"detailing|detail",i]'],
    "interior_cleaning": ['["amenity"="car_wash"]', '["name"~"interior|vacuum|detailing",i]'],
}

NOMINATIM_TERMS_BY_TAG: Dict[str, List[str]] = {
    "car_wash": ["car wash", "auto wash"],
    "car_cleaning": ["car cleaning", "auto cleaning", "car wash"],
    "car_drying": ["car detailing", "auto detailing", "car wash"],
    "car_polishing": ["car polishing", "car detailing", "auto detailing"],
    "car_detailing": ["car detailing", "auto detailing"],
    "interior_cleaning": ["interior car cleaning", "car detailing"],
}


class NearbySearchRequest(BaseModel):
    query: str = Field(..., min_length=2, max_length=300)
    user_lat: float = Field(..., ge=-90, le=90)
    user_lng: float = Field(..., ge=-180, le=180)
    radius_m: int = Field(DEFAULT_RADIUS_METERS, ge=250, le=MAX_RADIUS_METERS)
    max_results: int = Field(DEFAULT_MAX_RESULTS, ge=1, le=MAX_RESULTS)


class ParsedIntent(BaseModel):
    service_tags: List[str] = Field(default_factory=list)
    radius_m: Optional[int] = Field(default=None, ge=250, le=MAX_RADIUS_METERS)
    confidence: float = Field(default=0.0, ge=0, le=1)
    notes: str = ""


class NearbyPlace(BaseModel):
    name: str
    service_type: str
    lat: float
    lng: float
    distance_m: float
    source: str = "openstreetmap-overpass"


class NearbySearchResponse(BaseModel):
    query: str
    interpreted_tags: List[str]
    used_fallback_parser: bool
    radius_m: int
    places: List[NearbyPlace]
    warnings: List[str] = Field(default_factory=list)


app = FastAPI(title="Car Wash AI Nearby Services", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


def _haversine_meters(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371000
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)
    a = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
    return 2 * r * math.atan2(math.sqrt(a), math.sqrt(1 - a))


def _normalize_tags(tags: List[str]) -> List[str]:
    normalized = [tag.strip().lower() for tag in tags if tag and isinstance(tag, str)]
    return [tag for tag in normalized if tag in ALLOWED_SERVICE_TAGS]


def _fallback_parse_intent(query: str) -> ParsedIntent:
    q = query.lower()
    matched: List[str] = []
    for tag, keywords in SERVICE_KEYWORD_RULES.items():
        if any(keyword in q for keyword in keywords):
            matched.append(tag)
    if not matched:
        matched = ["car_wash"]

    radius_match = re.search(r"(\d+(?:\.\d+)?)\s?(m|meter|meters|km|kilometer|kilometers)", q)
    parsed_radius: Optional[int] = None
    if radius_match:
        value = float(radius_match.group(1))
        unit = radius_match.group(2)
        parsed_radius = int(value * 1000) if "km" in unit else int(value)

    return ParsedIntent(
        service_tags=matched,
        radius_m=parsed_radius,
        confidence=0.5,
        notes="Fallback parser used due to unavailable/invalid LLM output.",
    )


def _query_has_service_keywords(query: str) -> bool:
    q = query.lower()
    all_keywords: List[str] = []
    for keywords in SERVICE_KEYWORD_RULES.values():
        all_keywords.extend(keywords)
    return any(keyword in q for keyword in all_keywords)


def _parse_intent_with_gpt(query: str) -> ParsedIntent:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is missing")

    model_name = os.getenv("OPENAI_MODEL", "gpt-4.1-mini")
    client = OpenAI(api_key=api_key)

    system_prompt = (
        "You are a strict query normalizer for nearby car-care services. "
        "Never invent place names, coordinates, businesses, or facts. "
        "Return JSON only with keys: service_tags, radius_m, confidence, notes. "
        f"service_tags must be subset of: {sorted(ALLOWED_SERVICE_TAGS)}. "
        "If unsure, return empty service_tags and low confidence."
    )
    user_prompt = (
        "Extract the customer's intent for nearby services.\n"
        f"Query: {query}\n"
        "Rules:\n"
        "- No hallucinations.\n"
        "- Do not include coordinates.\n"
        "- radius_m optional, integer meters.\n"
        "- confidence between 0 and 1."
    )

    completion = client.chat.completions.create(
        model=model_name,
        response_format={"type": "json_object"},
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        temperature=0,
    )

    content = completion.choices[0].message.content or "{}"
    payload = json.loads(content)
    parsed = ParsedIntent(**payload)
    parsed.service_tags = _normalize_tags(parsed.service_tags)
    return parsed


def _build_overpass_query(lat: float, lng: float, radius_m: int, service_tags: List[str]) -> str:
    selectors: List[str] = []
    for tag in service_tags:
        selectors.extend(OSM_SELECTORS_BY_TAG.get(tag, []))

    if not selectors:
        selectors = OSM_SELECTORS_BY_TAG["car_wash"]
    else:
        # Always include generic car wash selectors to improve recall
        selectors.extend(OSM_SELECTORS_BY_TAG["car_wash"])

    clauses: List[str] = []
    for selector in selectors:
        clauses.append(f"node(around:{radius_m},{lat},{lng}){selector};")
        clauses.append(f"way(around:{radius_m},{lat},{lng}){selector};")
        clauses.append(f"relation(around:{radius_m},{lat},{lng}){selector};")

    return f"""
    [out:json][timeout:25];
    (
      {" ".join(clauses)}
    );
    out center tags;
    """


def _element_lat_lng(element: Dict[str, Any]) -> Optional[Tuple[float, float]]:
    if "lat" in element and "lon" in element:
        return float(element["lat"]), float(element["lon"])
    center = element.get("center")
    if isinstance(center, dict) and "lat" in center and "lon" in center:
        return float(center["lat"]), float(center["lon"])
    return None


def _infer_service_type(tags: Dict[str, Any], interpreted_tags: List[str]) -> str:
    name = str(tags.get("name", "")).lower()
    if "polish" in name or "wax" in name:
        return "car_polishing"
    if "detail" in name:
        return "car_detailing"
    if "interior" in name or "vacuum" in name:
        return "interior_cleaning"
    if interpreted_tags:
        return interpreted_tags[0]
    return "car_wash"


async def _search_overpass(lat: float, lng: float, radius_m: int, interpreted_tags: List[str], max_results: int) -> List[NearbyPlace]:
    query = _build_overpass_query(lat, lng, radius_m, interpreted_tags)
    data: Dict[str, Any] = {}
    last_error: Optional[Exception] = None
    headers = {
        "Content-Type": "text/plain; charset=utf-8",
        "Accept": "application/json",
        "User-Agent": "carwash-ai-nearby/1.0",
    }

    async with httpx.AsyncClient(timeout=25.0, follow_redirects=True) as client:
        for overpass_url in OVERPASS_URLS:
            try:
                response = await client.post(
                    overpass_url,
                    content=query,
                    headers=headers,
                )
                response.raise_for_status()
                data = response.json()
                break
            except (httpx.HTTPError, ValueError) as exc:
                last_error = exc
                continue

    if not data:
        raise HTTPException(
            status_code=502,
            detail=f"Nearby search provider failed: {last_error}",
        )

    places: List[NearbyPlace] = []
    seen_keys: Set[str] = set()
    for element in data.get("elements", []):
        coords = _element_lat_lng(element)
        if not coords:
            continue

        tags = element.get("tags", {})
        place_name = str(tags.get("name") or tags.get("brand") or "Unnamed Car Service").strip()
        place_lat, place_lng = coords
        distance = _haversine_meters(lat, lng, place_lat, place_lng)
        dedupe_key = f"{place_name.lower()}_{round(place_lat, 4)}_{round(place_lng, 4)}"
        if dedupe_key in seen_keys:
            continue
        seen_keys.add(dedupe_key)

        places.append(
            NearbyPlace(
                name=place_name,
                service_type=_infer_service_type(tags, interpreted_tags),
                lat=place_lat,
                lng=place_lng,
                distance_m=round(distance, 1),
            )
        )

    places.sort(key=lambda p: p.distance_m)
    return places[:max_results]


async def _search_nominatim_fallback(
    lat: float,
    lng: float,
    interpreted_tags: List[str],
    max_results: int,
) -> List[NearbyPlace]:
    terms: List[str] = []
    for tag in interpreted_tags:
        terms.extend(NOMINATIM_TERMS_BY_TAG.get(tag, []))
    if not terms:
        terms = ["car wash", "car detailing"]

    places: List[NearbyPlace] = []
    seen: Set[str] = set()
    headers = {"User-Agent": "carwash-ai-nearby/1.0", "Accept": "application/json"}

    async with httpx.AsyncClient(timeout=15.0, follow_redirects=True) as client:
        for term in terms:
            if len(places) >= max_results:
                break
            try:
                response = await client.get(
                    NOMINATIM_SEARCH_URL,
                    params={
                        "q": term,
                        "format": "jsonv2",
                        "limit": 8,
                        "addressdetails": 0,
                    },
                    headers=headers,
                )
                response.raise_for_status()
                data = response.json()
            except (httpx.HTTPError, ValueError):
                continue

            for item in data:
                try:
                    place_lat = float(item.get("lat"))
                    place_lng = float(item.get("lon"))
                except (TypeError, ValueError):
                    continue
                distance = _haversine_meters(lat, lng, place_lat, place_lng)
                name = str(item.get("display_name") or item.get("name") or "Car Service").split(",")[0].strip()
                dedupe_key = f"{name.lower()}_{round(place_lat, 4)}_{round(place_lng, 4)}"
                if dedupe_key in seen:
                    continue
                seen.add(dedupe_key)
                places.append(
                    NearbyPlace(
                        name=name,
                        service_type=interpreted_tags[0] if interpreted_tags else "car_wash",
                        lat=place_lat,
                        lng=place_lng,
                        distance_m=round(distance, 1),
                        source="nominatim-fallback",
                    )
                )
                if len(places) >= max_results:
                    break

    places.sort(key=lambda p: p.distance_m)
    return places[:max_results]


@app.get("/health")
async def health() -> Dict[str, str]:
    return {"status": "ok"}


@app.post("/ai/nearby-services", response_model=NearbySearchResponse)
async def nearby_services(request: NearbySearchRequest) -> NearbySearchResponse:
    used_fallback = False
    warnings: List[str] = []

    if not _query_has_service_keywords(request.query):
        help_text = (
            "Try queries like: 'car wash near me', 'car cleaning near me', "
            "'car polishing near me', or 'car drying near me'."
        )
        return NearbySearchResponse(
            query=request.query,
            interpreted_tags=[],
            used_fallback_parser=True,
            radius_m=request.radius_m,
            places=[],
            warnings=[
                "Your query was unclear for car wash services.",
                help_text,
            ],
        )

    try:
        parsed_intent = _parse_intent_with_gpt(request.query)
        if not parsed_intent.service_tags:
            warnings.append("LLM returned no valid service tags; fallback parser applied.")
            parsed_intent = _fallback_parse_intent(request.query)
            used_fallback = True
    except Exception:
        parsed_intent = _fallback_parse_intent(request.query)
        used_fallback = True
        warnings.append("LLM parse failed; fallback parser applied.")

    interpreted_tags = parsed_intent.service_tags or ["car_wash"]
    radius_m = parsed_intent.radius_m or request.radius_m
    radius_m = max(250, min(radius_m, MAX_RADIUS_METERS))

    try:
        places = await _search_overpass(
            lat=request.user_lat,
            lng=request.user_lng,
            radius_m=radius_m,
            interpreted_tags=interpreted_tags,
            max_results=request.max_results,
        )
    except HTTPException:
        places = await _search_nominatim_fallback(
            lat=request.user_lat,
            lng=request.user_lng,
            interpreted_tags=interpreted_tags,
            max_results=request.max_results,
        )
        warnings.append("Overpass provider failed; returned fallback nearby places.")
    except httpx.HTTPError:
        places = await _search_nominatim_fallback(
            lat=request.user_lat,
            lng=request.user_lng,
            interpreted_tags=interpreted_tags,
            max_results=request.max_results,
        )
        warnings.append("Nearby provider error; returned fallback nearby places.")

    if not places:
        warnings.append("No nearby matching services found in the selected radius.")
        warnings.append(
            "Try broader queries such as: 'car wash near me' or "
            "'car cleaning near me within 5 km'."
        )

    return NearbySearchResponse(
        query=request.query,
        interpreted_tags=interpreted_tags,
        used_fallback_parser=used_fallback,
        radius_m=radius_m,
        places=places,
        warnings=warnings,
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
