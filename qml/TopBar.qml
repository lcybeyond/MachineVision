import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root

    signal switchPage(int index)
    signal openGlobalVars()

    RowLayout {
        anchors.fill: parent
        spacing: 6
        Button {
            icon.source: "qrc:/icons/home.svg"
            icon.color: "transparent"
            onClicked: root.switchPage(0)
        }

        RowLayout{
            Layout.preferredWidth: root.width * 0.6
            Button {
                text: qsTr("运行")
                onClicked: root.switchPage(0)
            }
            Button {
                text: qsTr("连接")
                onClicked: root.switchPage(1)
            }
            Button {
                text: qsTr("布局")
                onClicked: root.switchPage(2)

            }
            Button {
                text: qsTr("脚本")
                onClicked: root.switchPage(3)
            }
            Button {
                text: qsTr("全局变量")
                onClicked: root.openGlobalVars()
            }
        }

        RowLayout{
            Layout.preferredWidth: root.width * 0.2
            Button {
                icon.source: "qrc:/icons/run.svg"
                icon.color: "transparent"
            }
            Button {
                icon.source: "qrc:/icons/pause.svg"
                icon.color: "transparent"
            }
        }

    }
}
