pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: systemMonitor

    function exec(command, callback) {
        var process = Qt.createQmlObject('import Quickshell.Io; Process {}', systemMonitor, 'dynamicProcess')
        process.command = ["sh", "-c", command]

        process.finished.connect(function() {
            if (callback) {
                callback(process.stdout)
            }
            process.destroy()
        })

        process.running = true
    }
}
