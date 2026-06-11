// 布局设置面板
// 用于配置运行视图中图像窗口的网格布局参数
// 用户可设置列数、窗口数、行间距和列间距，点击"应用布局"后通过信号通知外部

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Item {
    id: root

    // 应用布局信号，当用户点击"应用布局"按钮时发出
    // 参数：columns（列数）、windowCount（窗口数量）、rowSpacing（行间距）、columnSpacing（列间距）
    signal layoutApplied(int columns, int windowCount, real rowSpacing, real columnSpacing)

    // 组件初始化完成时记录日志
    Component.onCompleted: Logger.setStatus("布局设置初始化完成")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // 页面标题
        Label {
            text: "布局设置"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            color: "#e8e8f0"
        }

        // 网格布局参数卡片
        Rectangle {
            Layout.fillWidth: true
            color: "#1a1a2e"
            radius: 8
            border.color: "#252540"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // 卡片子标题
                Label {
                    text: "网格布局"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: "#9090a0"
                }

                // 参数输入区域，使用两列网格布局
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 16

                    // 列数设置：控制每行显示的窗口数量，范围 1~6
                    Label { text: "列数"; Layout.preferredWidth: 80; font.pixelSize: 12; color: "#9090a0" }
                    SpinBox {
                        id: columnsBox
                        from: 1; to: 6; value: 3; editable: true; Layout.fillWidth: true
                        font.pixelSize: 12
                        background: Rectangle { color: "#0f0f1a"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                        contentItem: TextInput {
                            text: parent.value; font.pixelSize: 12; color: "#e0e0f0"
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    // 窗口数设置：控制总共显示的图像窗口数量，范围 1~16
                    Label { text: "窗口数"; font.pixelSize: 12; color: "#9090a0" }
                    SpinBox {
                        id: windowCountBox
                        from: 1; to: 16; value: 6; editable: true; Layout.fillWidth: true
                        font.pixelSize: 12
                        background: Rectangle { color: "#0f0f1a"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                        contentItem: TextInput {
                            text: parent.value; font.pixelSize: 12; color: "#e0e0f0"
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    // 行间距设置：控制窗口之间的垂直间距，范围 0~50 像素
                    Label { text: "行间距"; font.pixelSize: 12; color: "#9090a0" }
                    SpinBox {
                        id: rowSpacingBox
                        from: 0; to: 50; value: 15; editable: true; Layout.fillWidth: true
                        font.pixelSize: 12
                        background: Rectangle { color: "#0f0f1a"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                        contentItem: TextInput {
                            text: parent.value; font.pixelSize: 12; color: "#e0e0f0"
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }

                    // 列间距设置：控制窗口之间的水平间距，范围 0~50 像素
                    Label { text: "列间距"; font.pixelSize: 12; color: "#9090a0" }
                    SpinBox {
                        id: colSpacingBox
                        from: 0; to: 50; value: 15; editable: true; Layout.fillWidth: true
                        font.pixelSize: 12
                        background: Rectangle { color: "#0f0f1a"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                        contentItem: TextInput {
                            text: parent.value; font.pixelSize: 12; color: "#e0e0f0"
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }
                }
            }
        }

        // "应用布局"按钮，点击后发出 layoutApplied 信号
        Rectangle {
            Layout.alignment: Qt.AlignRight
            Layout.preferredHeight: 36; Layout.preferredWidth: 120; radius: 6
            color: applyHover.hovered ? Qt.lighter("#0fabbc", 1.15) : "#0fabbc"
            Behavior on color { ColorAnimation { duration: 150 } }

            Label {
                anchors.centerIn: parent; text: "应用布局"; font.pixelSize: 12
                font.weight: Font.DemiBold; color: "#12121f"
            }
            MouseArea {
                id: applyHover; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.layoutApplied(columnsBox.value, windowCountBox.value,
                                       rowSpacingBox.value, colSpacingBox.value)
                }
                // 按下时缩小按钮产生点击反馈效果
                onPressed: parent.scale = 0.96
                onReleased: parent.scale = 1.0
            }
        }

        // 底部弹性空间，将内容推到顶部
        Item { Layout.fillHeight: true }
    }
}
