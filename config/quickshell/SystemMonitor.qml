pragma Singleton
import QtQuick 2.15
import Quickshell.Services.Process 1.0

QtObject {
    id: systemMonitor
    
    function exec(command, callback) {
        var process = processComponent.createObject(systemMonitor, {
            "command": ["sh", "-c", command]
        })
        
        process.finished.connect(function() {
            if (callback) {
                callback(process.stdout)
            }
            process.destroy()
        })
        
        process.start()
    }
    
    Component {
        id: processComponent
        Process {
            property var callback
        }
    }
}
