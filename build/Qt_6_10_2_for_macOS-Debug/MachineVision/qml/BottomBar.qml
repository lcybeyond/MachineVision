import QtQuick
import com.lcy.systemMonitor
Item {
    id: root
    SystemMonitor{
        id: sysMonitor
    }
    Rectangle {
        width: root.width
        height: root.height
        color: "white"
        Text {
            text: sysMonitor.memoryUsage + "%"
        }
    }
}
