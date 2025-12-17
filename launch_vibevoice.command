#!/bin/bash

# VibeVoice Realtime TTS Launcher
# Double-click this file to start the server and open the web interface

# Change to the repository root directory
cd "$(dirname "$0")"

echo "================================================"
echo "  VibeVoice Realtime TTS Launcher"
echo "================================================"
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is not installed"
    echo ""
    echo "Please install Python 3.9 or later from:"
    echo "https://www.python.org/downloads/"
    echo ""
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
echo "✓ Found Python $PYTHON_VERSION"

# Check if pip3 is installed
if ! command -v pip3 &> /dev/null; then
    echo "❌ Error: pip3 is not installed"
    echo ""
    echo "Press any key to exit..."
    read -n 1
    exit 1
fi

echo "✓ Found pip3"
echo ""

# Check if vibevoice is installed
if ! python3 -c "import vibevoice" 2>/dev/null; then
    echo "================================================"
    echo "  First-time setup detected"
    echo "================================================"
    echo ""
    echo "Installing VibeVoice and dependencies..."
    echo "This will take a few minutes."
    echo ""
    
    # Upgrade pip first
    echo "→ Upgrading pip..."
    python3 -m pip install --upgrade pip --user --quiet
    
    # Install the package
    echo "→ Installing vibevoice package..."
    if pip3 install . --user; then
        echo ""
        echo "✅ Installation successful!"
        echo ""
    else
        echo ""
        echo "❌ Installation failed"
        echo ""
        echo "Press any key to exit..."
        read -n 1
        exit 1
    fi
else
    echo "✓ VibeVoice package is installed"
    echo ""
fi

# Check if voice presets exist
if [ ! -d "demo/voices/streaming_model" ] || [ -z "$(ls -A demo/voices/streaming_model 2>/dev/null)" ]; then
    echo "================================================"
    echo "  Downloading voice presets"
    echo "================================================"
    echo ""
    echo "Voice presets not found. Downloading..."
    echo ""
    
    cd demo
    if [ -f "download_experimental_voices.sh" ]; then
        bash download_experimental_voices.sh
        cd ..
        echo ""
        echo "✅ Voice presets downloaded!"
        echo ""
    else
        cd ..
        echo "⚠️  Warning: Could not find voice download script"
        echo "The server will use default voices only."
        echo ""
    fi
else
    VOICE_COUNT=$(ls -1 demo/voices/streaming_model/*.pt 2>/dev/null | wc -l | tr -d ' ')
    echo "✓ Found $VOICE_COUNT voice presets"
    echo ""
fi

echo "================================================"
echo "  Starting server"
echo "================================================"
echo ""
echo "Loading model... This may take 1-2 minutes."
echo ""

# Detect device (mps for Mac with Apple Silicon, cuda for NVIDIA GPU, cpu otherwise)
DEVICE="cpu"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Check if Mac has Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        DEVICE="mps"
        echo "✓ Detected Apple Silicon - using MPS acceleration"
    else
        echo "✓ Detected Intel Mac - using CPU"
    fi
elif command -v nvidia-smi &> /dev/null; then
    DEVICE="cuda"
    echo "✓ Detected NVIDIA GPU - using CUDA acceleration"
else
    echo "✓ Using CPU (no GPU detected)"
fi
echo ""

# Start the server in the background
cd demo
python3 vibevoice_realtime_demo.py --device $DEVICE --port 3000 &
SERVER_PID=$!

echo "Server process started (PID: $SERVER_PID)"
echo "Waiting for server to initialize..."
echo ""

# Wait for the server to be ready (check if port 3000 is listening)
MAX_WAIT=120
WAITED=0
while ! lsof -i :3000 > /dev/null 2>&1; do
    if [ $WAITED -ge $MAX_WAIT ]; then
        echo "Error: Server failed to start within $MAX_WAIT seconds"
        kill $SERVER_PID 2>/dev/null
        echo ""
        echo "Press any key to exit..."
        read -n 1
        exit 1
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    echo -n "."
done

echo ""
echo ""
echo "✅ Server is ready!"
echo ""
echo "================================================"
echo "  Opening web browser..."
echo "================================================"
echo ""

# Open the browser
open http://127.0.0.1:3000

echo "VibeVoice is now running at: http://127.0.0.1:3000"
echo ""
echo "================================================"
echo "  Instructions:"
echo "================================================"
echo "• The web interface should open automatically"
echo "• Enter text and click 'Start' to generate speech"
echo "• Choose different voices from the dropdown"
echo "• Adjust CFG and Inference Steps for quality"
echo ""
echo "To stop the server:"
echo "• Close this terminal window, or"
echo "• Press Ctrl+C in this window"
echo ""
echo "================================================"

# Keep the terminal open and wait for the server process
echo "Server is running... (Ctrl+C to stop)"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down server..."
    kill $SERVER_PID 2>/dev/null
    wait $SERVER_PID 2>/dev/null
    echo "Server stopped."
    exit 0
}

# Trap Ctrl+C and terminal close
trap cleanup INT TERM

# Wait for the server process
wait $SERVER_PID
