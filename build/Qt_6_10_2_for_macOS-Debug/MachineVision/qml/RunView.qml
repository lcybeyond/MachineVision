import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int columns: 3
    property int windowCount: 6
    property real rowSpacing: 15
    property real columnSpacing: 15

    GridLayout {
        anchors.margins: 10
        anchors.fill: parent

        columns: root.columns
        rowSpacing: root.rowSpacing
        columnSpacing: root.columnSpacing

        Repeater {
            model: root.windowCount
            ImageWindow {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}
