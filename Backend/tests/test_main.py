from main import ParsedIntent, _fallback_parse_intent, _haversine_meters, _normalize_tags


def test_normalize_tags_filters_unknown_values() -> None:
    tags = _normalize_tags(["car_wash", "INVALID", "car_polishing", ""])
    assert tags == ["car_wash", "car_polishing"]


def test_fallback_parser_detects_keywords() -> None:
    parsed = _fallback_parse_intent("Need car polishing and interior cleaning near me")
    assert "car_polishing" in parsed.service_tags
    assert "interior_cleaning" in parsed.service_tags
    assert 0 <= parsed.confidence <= 1


def test_fallback_parser_extracts_radius() -> None:
    parsed = _fallback_parse_intent("Find washing services within 3 km")
    assert isinstance(parsed, ParsedIntent)
    assert parsed.radius_m == 3000


def test_haversine_distance_zero_for_same_point() -> None:
    distance = _haversine_meters(31.5204, 74.3587, 31.5204, 74.3587)
    assert distance == 0
