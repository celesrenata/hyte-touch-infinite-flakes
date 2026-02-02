#!/usr/bin/env python3
import sys
import struct
import math
import numpy as np
from scipy import signal

# Simple FFT audio analyzer for Tidal
RATE = 44100
CHUNK = 2048
BANDS = 32

def analyze_audio():
    while True:
        # Read audio chunk
        data = sys.stdin.buffer.read(CHUNK * 2)
        if not data:
            break
            
        # Convert to samples
        samples = np.frombuffer(data, dtype=np.int16).astype(np.float32) / 32768.0
        
        # Apply window
        windowed = samples * signal.windows.hann(len(samples))
        
        # FFT
        fft = np.abs(np.fft.rfft(windowed))
        
        # Split into bands
        band_size = len(fft) // BANDS
        bands = []
        for i in range(BANDS):
            start = i * band_size
            end = start + band_size
            band_power = np.mean(fft[start:end])
            bands.append(min(band_power * 10, 1.0))
        
        # Calculate bass (first 4 bands), mid (next 12), treble (rest)
        bass = np.mean(bands[:4])
        mid = np.mean(bands[4:16])
        treble = np.mean(bands[16:])
        overall = np.mean(bands)
        
        # Output: bass mid treble overall band1 band2 ... band32
        output = f"{bass:.4f} {mid:.4f} {treble:.4f} {overall:.4f}"
        for b in bands:
            output += f" {b:.4f}"
        print(output, flush=True)

if __name__ == "__main__":
    analyze_audio()
