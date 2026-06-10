import QtQuick
import QtQuick.Layouts
import com.lcy.systemMonitor
import com.lcy.algorithmManager

Item {
    id: root

    SystemMonitor {
        id: sysMonitor
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 120
            Layout.fillHeight: true
            color: "white"
            Text {
                anchors.centerIn: parent
                text: "内存: " + sysMonitor.memoryUsage + "%"
                font.pixelSize: 12
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"
            radius: 4
            clip: true

            Text {
                anchors.fill: parent
                anchors.margins: 8
                verticalAlignment: Text.AlignVCenter
                text: Logger.statusText
                font.pixelSize: 12
                color: "#333333"
                elide: Text.ElideRight
            }
        }
    }
}
