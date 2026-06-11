import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.systemMonitor
import com.lcy.algorithmManager

// 底部状态栏 —— 显示系统运行时信息，包括内存使用率、状态文本和版本号
// 内存使用率通过进度条和百分比数字展示，并根据阈值变化颜色（绿/黄/红）
Item {
    id: root

    // 系统监控对象，提供 CPU、内存等系统资源使用数据
    SystemMonitor {
        id: sysMonitor
    }

    // 组件初始化完成，记录日志
    Component.onCompleted: Logger.setStatus("状态栏初始化完成")

    // 状态栏背景
    Rectangle {
        anchors.fill: parent
        color: "#12121f"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            // 内存使用率显示区域 —— 包含标签、进度条和百分比数字
            RowLayout {
                spacing: 8
                Layout.alignment: Qt.AlignVCenter

                // "内存" 标签
                Label {
                    text: "内存"
                    font.pixelSize: 11
                    color: "#707088"
                }

                // 内存使用率进度条 —— 宽度随内存使用率动态变化
                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 6
                    radius: 3
                    // 进度条轨道背景色
                    color: "#252540"

                    // 进度条填充部分，宽度绑定到内存使用率百分比
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        // 内存使用率 0-100 映射为进度条宽度
                        width: parent.width * (sysMonitor.memoryUsage / 100)
                        radius: 3
                        // 颜色根据内存使用率阈值变化：>80% 红色，>60% 黄色，否则绿色
                        color: {
                            var mem = sysMonitor.memoryUsage
                            if (mem > 80) return "#e74c3c"
                            if (mem > 60) return "#f39c12"
                            return "#0fabbc"
                        }
                        // 宽度变化动画，平滑过渡
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }
                }

                // 内存使用率百分比数字显示
                Label {
                    text: sysMonitor.memoryUsage + "%"
                    font.pixelSize: 11
                    // 文字颜色同样根据阈值变化
                    color: {
                        var mem = sysMonitor.memoryUsage
                        if (mem > 80) return "#e74c3c"
                        if (mem > 60) return "#f39c12"
                        return "#9090a0"
                    }
                    font.weight: Font.DemiBold
                }
            }

            // 分隔线
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: "#2d2d45"
            }

            // 状态信息显示区域 —— 包含闪烁指示灯和状态文本
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                // 状态指示灯 —— 通过透明度动画实现呼吸灯效果，表示系统正在运行
                Rectangle {
                    width: 7
                    height: 7
                    radius: 3.5
                    color: statusDotBlink.colorValue
                    PropertyAnimation on opacity {
                        id: statusDotBlink
                        // 指示灯颜色
                        property color colorValue: "#0fabbc"
                        running: true
                        from: 0.4; to: 1.0
                        duration: 800
                        // 无限循环播放
                        loops: Animation.Infinite
                        easing.type: Easing.InOutSine
                    }
                }

                // 状态文本，绑定到 Logger 的状态消息，过长时右侧省略
                Label {
                    text: Logger.statusText
                    font.pixelSize: 11
                    color: "#9090a0"
                    elide: Text.ElideRight
                }
            }

            // 分隔线
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 16
                color: "#2d2d45"
            }

            // 版本号显示
            Label {
                text: "v0.1"
                font.pixelSize: 10
                color: "#606078"
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
