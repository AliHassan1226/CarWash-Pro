# Backend Run Guide

Follow these steps from the `Backend` folder.

## 1) Create a virtual environment

```powershell
py -m venv venv
```

## 2) Activate the virtual environment

```powershell
.\venv\Scripts\activate
```

If PowerShell blocks scripts, run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\venv\Scripts\activate
```

## 3) Install dependencies

```powershell
pip install -r requirements.txt
```

## 4) Run the backend

```powershell
py main.py
```

The API runs on:

- `http://0.0.0.0:8000`
- Local test URL: `http://127.0.0.1:8000`
- LAN URL (for Flutter device on same Wi-Fi): `http://192.168.100.5:8000`
