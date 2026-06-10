import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts

import "./qml"

ApplicationWindow {
    width: 800
    height: 600
    visible: true
    title: "上中下布局（顶部独立QML）"



    ColumnLayout {
        anchors.fill: parent

        TopBar {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.1
        }

        MainContent {
            id: mainContent
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Connections {
            target: topBar
            function onSwitchPage(index) {
                mainContent.changeIndex(index)
            }
        }

        // ========== 底部 ==========
        BottomBar {
            id: bottomBar
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.1
        }
    }
}
