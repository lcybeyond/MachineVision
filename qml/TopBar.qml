// 顶部导航栏
// 包含应用 Logo、四个导航标签（运行/连接/布局/脚本）和全局变量按钮
// 点击 Logo 或导航标签会通过 switchPage 信号通知外部切换页面
// 当前激活的标签页有高亮颜色和底部指示条动画

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Item {
    id: root

    // 页面切换信号，参数为目标页面索引：0:运行, 1:连接, 2:布局, 3:脚本
    signal switchPage(int index)
    // 打开全局变量弹窗信号
    signal openGlobalVars()

    // 当前激活的页面索引
    property int currentPage: 0

    // 组件初始化完成时记录日志
    Component.onCompleted: Logger.setStatus("导航栏初始化完成")

    Rectangle {
        anchors.fill: parent
        color: "#12121f"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 0

            // Logo 按钮：显示"MV"文字，点击回到首页（运行页面）
            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 10
                color: "#0fabbc"
                Layout.alignment: Qt.AlignVCenter

                Label {
                    anchors.centerIn: parent
                    text: "MV"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#12121f"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.currentPage = 0
                        root.switchPage(0)
                    }
                }
            }

            // Logo 与导航标签之间的间距
            Item { Layout.preferredWidth: 20 }

            // 导航标签列表，使用 Repeater 根据数据模型动态生成
            // 每个标签包含图标和文字，激活状态时有高亮背景和指示条
            Repeater {
                model: [
                    { text: "运行", icon: "▶" },
                    { text: "连接", icon: "⚫" },
                    { text: "布局", icon: "▦" },
                    { text: "脚本", icon: "<>" }
                ]

                // 单个导航标签
                Rectangle {
                    Layout.preferredWidth: navText.implicitWidth + 32
                    Layout.fillHeight: true
                    // 激活标签有背景高亮色
                    color: root.currentPage === index ? "#1e1e38" : "transparent"
                    radius: 8

                    // 背景色切换动画
                    Behavior on color { ColorAnimation { duration: 200 } }

                    // 标签内容：图标和文字水平排列
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        // 图标文字，激活状态使用主题色
                        Label {
                            text: modelData.icon
                            font.pixelSize: 12
                            color: root.currentPage === index ? "#0fabbc" : "#707088"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        // 标签文字，激活状态加粗并使用亮色
                        Label {
                            id: navText
                            text: modelData.text
                            font.pixelSize: 13
                            font.weight: root.currentPage === index ? Font.DemiBold : Font.Normal
                            color: root.currentPage === index ? "#e8e8f0" : "#9090a0"
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                    }

                    // 点击标签时切换页面
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentPage = index
                            root.switchPage(index)
                        }
                    }

                    // 底部激活指示条，仅在当前激活标签下显示
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width * 0.5
                        height: 2
                        radius: 1
                        color: root.currentPage === index ? "#0fabbc" : "transparent"
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            // 弹性空间，将全局变量按钮推到右侧
            Item { Layout.fillWidth: true }

            // "全局变量"按钮：点击发出 openGlobalVars 信号
            Rectangle {
                Layout.preferredWidth: globalVarBtn.implicitWidth + 24
                Layout.preferredHeight: 34
                radius: 17
                color: globalVarHover.hovered ? "#252540" : "transparent"
                Layout.alignment: Qt.AlignVCenter
                Behavior on color { ColorAnimation { duration: 150 } }

                Label {
                    id: globalVarBtn
                    anchors.centerIn: parent
                    text: "全局变量"
                    font.pixelSize: 12
                    color: "#9090a0"
                }

                MouseArea {
                    id: globalVarHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openGlobalVars()
                }
            }
        }
    }
}
