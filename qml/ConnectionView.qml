import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root
    RowLayout{
        id: rowLayout
        anchors.margins: 10
        anchors.fill: parent

        ColumnLayout{
            id: columnLayout
            Layout.preferredWidth: parent.width * 0.2
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop
            Repeater{
                model: 3
                Button{
                    text: "连接"
                }
            }
            Button{
                icon.source: "qrc:/icons/add.svg"
                icon.color: "transparent"
                onClicked: stackLayout.currentIndex = 0
            }
        }
        StackLayout{
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: 1

            ConnectionSetting {
              id: connectionSettings
              Layout.fillWidth: true
              Layout.fillHeight: true
          }

            Rectangle {
                color: 'green'
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

        }
    }
}
