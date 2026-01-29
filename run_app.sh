#!/bin/bash
# PPALI 2 Startup Script (Linux/Mac)

# 1. Detect Python Command
if command -v python3 &>/dev/null; then
    PYTHON_CMD=python3
else
    PYTHON_CMD=python
fi

# 2. Check for Virtual Environment (Standard Locations)
if [ -d "../venv" ]; then
    PYTHON_CMD="../venv/bin/python"
elif [ -d "venv" ]; then
    PYTHON_CMD="venv/bin/python"
fi

echo "Using Python: $PYTHON_CMD"

# 3. Search for pip module properly (python -m pip is safest)
echo "Installing dependencies..."
$PYTHON_CMD -m pip install -r requirements.txt || echo "Pip install failed or requirements satisfied."

# 4. Run Backend
cd backend
$PYTHON_CMD main.py
