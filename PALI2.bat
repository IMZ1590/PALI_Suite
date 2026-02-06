@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title PALI 2 Launcher

set "PY_DIR=python_runtime"
set "VENV_DIR=venv"
set "PY_ZIP=python_embed.zip"
set "PY_URL=https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip"
set "GET_PIP_URL=https://bootstrap.pypa.io/get-pip.py"

set PORT=7777

for /f "tokens=5" %%a in ('netstat -aon ^| findstr :%PORT% ^| findstr LISTENING') do (
    taskkill /f /t /pid %%a >nul 2>&1
)

if not exist "%PY_DIR%\python.exe" (
    if exist "%PY_ZIP%" del "%PY_ZIP%"
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%PY_URL%' -OutFile '%PY_ZIP%'"
    if not exist "%PY_DIR%" mkdir "%PY_DIR%"
    powershell -Command "Expand-Archive -Path '%PY_ZIP%' -DestinationPath '%PY_DIR%' -Force"
    del "%PY_ZIP%"
    (
    echo python310.zip
    echo .
    echo lib
    echo site-packages
    echo import site
    ) > "%PY_DIR%\python310._pth"
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%GET_PIP_URL%' -OutFile 'get-pip.py'"
    "%PY_DIR%\python.exe" get-pip.py
    del "get-pip.py"
)

if not exist "%VENV_DIR%" (
    "%PY_DIR%\python.exe" -m pip install virtualenv
    "%PY_DIR%\python.exe" -m virtualenv "%VENV_DIR%"
)

set PYTHONPATH=
set PYTHONHOME=
call "%VENV_DIR%\Scripts\activate"

python -m pip install --upgrade pip --no-warn-script-location
python -m pip install numpy uvicorn fastapi python-multipart nmrglue --no-warn-script-location
if exist "backend\requirements.txt" (
    python -m pip install -r backend\requirements.txt --no-warn-script-location
)

echo.
echo [INFO] Starting Server... Browser will open automatically when ready.

start /b cmd /c "for /l %%i in (1,1,60) do (timeout /t 1 >nul & netstat -an | findstr ":%PORT%" | findstr "LISTENING" >nul && (start "" "http://127.0.0.1:%PORT%" & exit))"

python -m uvicorn backend.main:app --host 127.0.0.1 --port %PORT%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Server stopped unexpectedly.
    pause
)
