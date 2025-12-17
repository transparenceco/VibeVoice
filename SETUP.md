# Quick Setup Guide for VibeVoice

## 🚀 One-Click Setup (Recommended)

### For macOS:
1. **Double-click** `launch_vibevoice.command`
2. Wait for automatic setup to complete (first time only)
3. Browser opens automatically to the TTS interface

That's it! The script automatically:
- ✅ Checks for Python 3.9+
- ✅ Installs all dependencies
- ✅ Downloads voice presets
- ✅ Detects your hardware (Apple Silicon MPS, NVIDIA CUDA, or CPU)
- ✅ Starts the server
- ✅ Opens your browser

### For Linux/Windows:
Run the following in terminal:
```bash
# Install dependencies
pip3 install .

# Download voice presets
cd demo
bash download_experimental_voices.sh
cd ..

# Start the server
cd demo
python3 vibevoice_realtime_demo.py --device cuda --port 3000  # Use cuda, mps, or cpu
```

Then open http://127.0.0.1:3000 in your browser.

---

## 📋 Requirements

- **Python**: 3.9 or later
- **RAM**: 4GB minimum, 8GB+ recommended
- **Storage**: ~3GB for model and dependencies
- **GPU** (optional): Apple Silicon (M1/M2/M3), NVIDIA GPU with CUDA, or CPU

---

## 🎙️ Using the Interface

1. **Enter text** in the text box
2. **Select a speaker** from the dropdown (25 voices available)
3. **Adjust settings** (optional):
   - **CFG Scale** (1.3-3.0): Lower = more natural, Higher = more accurate
   - **Inference Steps** (5-20): Fewer = faster, More = better quality
4. **Click "Start"** to generate and hear speech
5. **Click "Save"** to download the generated audio

---

## 🔧 Troubleshooting

### "Can't connect to localhost"
- Make sure the server started successfully (check the terminal window)
- Try using `http://127.0.0.1:3000` instead of `http://localhost:3000`
- Check if another application is using port 3000

### "Python not found"
- Install Python 3.9+ from https://www.python.org/downloads/
- On Mac, you can also use Homebrew: `brew install python3`

### "Installation failed"
- Make sure you have internet connection
- Try running: `python3 -m pip install --upgrade pip`
- Then run the launcher again

### Slow performance
- First generation is always slower (loading model into memory)
- Increase inference steps only if you need better quality
- On CPU, generation will be slower than real-time

---

## 📝 Advanced Options

### Change port:
Edit `launch_vibevoice.command` and change `--port 3000` to your desired port.

### Manual device selection:
Edit `launch_vibevoice.command` and change the `DEVICE` variable to:
- `mps` - Apple Silicon GPU
- `cuda` - NVIDIA GPU  
- `cpu` - CPU only

### Add more voices:
Place `.pt` voice preset files in `demo/voices/streaming_model/`

---

## 📚 More Information

- **Full documentation**: See `docs/vibevoice-realtime-0.5b.md`
- **Main README**: See `README.md`
- **Issues**: https://github.com/microsoft/VibeVoice/issues
