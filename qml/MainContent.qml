import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root
    function changeIndex(index) {
        contentLayout.currentIndex = index
    }
    StackLayout {
        id: contentLayout
        currentIndex: 0
        anchors.fill: parent

        RunView {
            id: runView
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ConnectionView {
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        LayoutSetting {
            id: layoutSettings
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Connections {
        target: layoutSettings
        function onLayoutApplied(columns, windowCount, rowSpacing, columnSpacing) {
            runView.columns = columns
            runView.windowCount = windowCount
            runView.rowSpacing = rowSpacing
            runView.columnSpacing = columnSpacing
        }
    }
}
