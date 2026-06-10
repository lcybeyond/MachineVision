import QtQuick
import QtQuick.Layouts

Item {
    id: root

    signal modifyScriptMgr(int index)

    property int columns: 3
    property int windowCount: 6
    property real rowSpacing: 15
    property real columnSpacing: 15
    property var scriptMgr: null

    GridLayout {
        anchors.margins: 10
        anchors.fill: parent

        columns: root.columns
        rowSpacing: root.rowSpacing
        columnSpacing: root.columnSpacing

        Repeater {
            id: repeater
            model: root.windowCount
            ImageWindow {
                Layout.fillHeight: true
                Layout.fillWidth: true

                windowIndex: index
            }
            Component.onCompleted: {
                scriptMgr.ensureCount(repeater.count+1)
                for (var i = 0; i < repeater.count; i++) {
                    repeater.itemAt(i).windowScriptEngine = scriptMgr.engineAt(i)
                }
                modifyScriptMgr(repeater.count)
            }
            onCountChanged: {
                scriptMgr.ensureCount(repeater.count+1)
                for (var i = 0; i < repeater.count; i++) {
                    repeater.itemAt(i).windowScriptEngine = scriptMgr.engineAt(i)
                }
                modifyScriptMgr(repeater.count)
            }
        }
    }
}
