pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: audioMonitor
    
    property real bass: 0.0
    property real mid: 0.0
    property real treble: 0.0
    property real overall: 0.0
    property var bands: []
    
    onBassChanged: console.log(Date.now(), "Bass changed:", bass)
    
    // Smoothed values for rendering
    property real smoothBass: 0.0
    property real smoothMid: 0.0
    property real smoothTreble: 0.0
    
    // Smooth interpolation timer
    property var smoothTimer: Timer {
        running: true
        repeat: true
        interval: 16  // 60fps
        onTriggered: {
            // Smooth interpolation
            audioMonitor.smoothBass += (audioMonitor.bass - audioMonitor.smoothBass) * 0.3
            audioMonitor.smoothMid += (audioMonitor.mid - audioMonitor.smoothMid) * 0.3
            audioMonitor.smoothTreble += (audioMonitor.treble - audioMonitor.smoothTreble) * 0.3
        }
    }
    
    property bool enableBackgroundPulse: true
    property bool enableBorderGlow: false
    property bool enableSpectrumBars: false
    
    property var fftProcess: Process {
        running: true
        command: ["/run/current-system/sw/bin/sh", "-c",
            "parec --format=s16le --rate=44100 --channels=1 | python3 /home/celes/.config/quickshell/touch/audio-fft.py"]
        
        stdout: SplitParser {
            splitMarker: "\n"
            
            onRead: data => {
                var values = data.split(' ')
                if (values.length >= 36) {
                    var newBass = parseFloat(values[0])
                    if (Math.abs(newBass - audioMonitor.bass) > 0.01) {
                        console.log("Bass:", audioMonitor.bass, "->", newBass)
                    }
                    audioMonitor.bass = newBass
                    audioMonitor.mid = parseFloat(values[1])
                    audioMonitor.treble = parseFloat(values[2])
                    audioMonitor.overall = parseFloat(values[3])
                    
                    var newBands = []
                    for (var j = 4; j < values.length; j++) {
                        newBands.push(parseFloat(values[j]))
                    }
                    audioMonitor.bands = newBands
                }
            }
        }
        
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                console.log("FFT stderr:", data)
            }
        }
    }
    
    function getBackgroundColor() {
        if (!enableBackgroundPulse) return "#1a1a1a"
        
        var r = Math.floor(26 + bass * 40)
        var g = Math.floor(26 + mid * 40)
        var b = Math.floor(26 + treble * 40)
        return "#" + r.toString(16).padStart(2, '0') + 
                     g.toString(16).padStart(2, '0') + 
                     b.toString(16).padStart(2, '0')
    }
    
    function getBorderGlow() {
        if (!enableBorderGlow) return 0
        return overall * 10
    }
}
