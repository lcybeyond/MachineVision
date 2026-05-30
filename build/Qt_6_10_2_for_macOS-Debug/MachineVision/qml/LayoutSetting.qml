import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root

    // 发给外部的信号，携带布局参数
    signal layoutApplied(int columns, int windowCount, real rowSpacing, real columnSpacing)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        Label {
            text: "布局设置"
            font.pixelSize: 18
            font.bold: true
        }

        GroupBox {
            title: "网格布局"
            Layout.fillWidth: true

            background: Rectangle {
                y: parent.topPadding - parent.bottomPadding
                width: parent.width
                height: parent.height - parent.topPadding + parent.bottomPadding
                color: "transparent"
                border.color: "#e0e0e0"
                radius: 6
            }

            GridLayout {
                anchors.fill: parent
                columns: 2
                rowSpacing: 14
                columnSpacing: 16

                Label {
                    text: "列数"
                    Layout.preferredWidth: 80
                    font.pixelSize: 13
                }
                SpinBox {
                    id: columnsBox
                    from: 1
                    to: 6
                    value: 3
                    editable: true
                    Layout.fillWidth: true
                }

                Label {
                    text: "窗口数"
                    font.pixelSize: 13
                }
                SpinBox {
                    id: windowCountBox
                    from: 1
                    to: 16
                    value: 6
                    editable: true
                    Layout.fillWidth: true
                }

                Label {
                    text: "行间距"
                    font.pixelSize: 13
                }
                SpinBox {
                    id: rowSpacingBox
                    from: 0
                    to: 50
                    value: 15
                    editable: true
                    Layout.fillWidth: true
                }

                Label {
                    text: "列间距"
                    font.pixelSize: 13
                }
                SpinBox {
                    id: colSpacingBox
                    from: 0
                    to: 50
                    value: 15
                    editable: true
                    Layout.fillWidth: true
                }
            }
        }

        Button {
            text: "应用布局"
            Layout.preferredWidth: 120
            Layout.preferredHeight: 36
            onClicked: {
                root.layoutApplied(columnsBox.value, windowCountBox.value,
                                   rowSpacingBox.value, colSpacingBox.value)
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
