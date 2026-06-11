// 图像显示窗口组件
// 用于在运行视图中展示单个算法窗口的图像结果
// 支持图像的鼠标拖拽平移、滚轮缩放、双击重置视图
// 底部状态栏显示检测结果（ok / ng / 待检测），结果变化时有动画效果
// 右上角配置按钮可打开算法参数设置对话框

import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import com.lcy.algorithmManager

Item {
    id: root
    width: 200
    height: 200
    // 关联的脚本引擎实例，提供图像 URL 和检测结果
    property var windowScriptEngine: null
    // 窗口在网格中的序号，用于显示索引和关联对应算法
    property var windowIndex: null

    // 组件初始化完成时记录日志
    Component.onCompleted: Logger.setStatus("图像窗口" + (windowIndex !== null ? windowIndex + 1 : "") + "初始化完成")

    // 卡片背景容器，提供圆角和边框样式
    Rectangle {
        anchors.fill: parent
        anchors.margins: 4
        color: "#1a1a2e"
        radius: 8
        border.color: "#252540"
        border.width: 1

        // 顶部内侧高亮边缘，模拟细微的内阴影效果
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: "#2d2d50"
            radius: 8
        }

        // 左上角的序号徽章，显示当前窗口编号
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 8
            width: 24
            height: 24
            radius: 12
            color: "#252540"

            Label {
                anchors.centerIn: parent
                text: windowIndex !== null ? windowIndex + 1 : ""
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: "#9090a0"
            }
        }

        // 图像显示区域，支持拖拽、缩放等交互
        Item {
            id: imageArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: statusBar.top
            anchors.margins: 4
            anchors.topMargin: 36
            clip: true

            // 棋盘格背景，表示空白/透明区域
            Rectangle {
                anchors.fill: parent
                color: "#0f0f1a"
                radius: 4

                // 棋盘格图案，以 4x3 的马赛克排列，交替两种颜色
                Repeater {
                    model: 12
                    Rectangle {
                        x: (index % 4) * (imageArea.width / 4)
                        y: Math.floor(index / 4) * (imageArea.height / 3)
                        width: imageArea.width / 4
                        height: imageArea.height / 3
                        color: (Math.floor(index / 4) + index % 4) % 2 === 0 ? "#141428" : "#181830"
                    }
                }
            }

            // 图像容器，支持缩放变换
            Item {
                id: imgContainer
                width: parent.width
                height: parent.height

                // 当前缩放比例
                property real scaleVal: 1.0

                // 缩放变换，基于 scaleVal 属性对容器进行等比缩放
                transform: Scale {
                    id: imgScale
                    xScale: imgContainer.scaleVal
                    yScale: imgContainer.scaleVal
                }

                // 结果图像，源来自脚本引擎的结果图像 URL
                Image {
                    id: image
                    anchors.fill: parent
                    source: {
                        if (windowScriptEngine && windowScriptEngine.resultImageUrl) {
                            var p = windowScriptEngine.resultImageUrl
                            // 确保路径以 file:// 协议开头
                            if (p.startsWith("/")) return "file://" + p
                            return "file:///" + p
                        }
                        return ""
                    }
                    fillMode: Image.PreserveAspectFit
                    cache: false
                    visible: source != ""
                }

                // 无图像时的占位提示文字
                Label {
                    anchors.centerIn: parent
                    text: image.source == "" ? "无图像" : ""
                    font.pixelSize: 13
                    color: "#505068"
                    visible: image.source == ""
                }
            }

            // 鼠标交互区域，支持以下操作：
            // - 按下拖拽平移图像
            // - 滚轮缩放图像
            // - 双击重置视图（缩放=1，位置归零）
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true

                property real lastX: 0
                property real lastY: 0
                property bool dragging: false

                // 按下鼠标时记录起始坐标，开始拖拽
                onPressed: function(mouse) {
                    lastX = mouse.x; lastY = mouse.y; dragging = true
                }
                // 拖拽时根据鼠标位移平移图像容器
                onPositionChanged: function(mouse) {
                    if (!dragging) return
                    imgContainer.x += mouse.x - lastX
                    imgContainer.y += mouse.y - lastY
                    lastX = mouse.x; lastY = mouse.y
                }
                // 释放鼠标时结束拖拽
                onReleased: { dragging = false }
                // 滚轮缩放：以鼠标位置为中心进行缩放
                onWheel: function(wheel) {
                    wheel.accepted = true
                    var oldScale = imgContainer.scaleVal
                    var factor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                    // 缩放范围限制在 0.3 ~ 5.0 之间
                    var newScale = Math.max(0.3, Math.min(5.0, oldScale * factor))
                    if (Math.abs(newScale - oldScale) < 0.001) return
                    // 以鼠标位置为锚点进行缩放，保持鼠标指向的图像位置不变
                    imgContainer.x = wheel.x - (wheel.x - imgContainer.x) * (newScale / oldScale)
                    imgContainer.y = wheel.y - (wheel.y - imgContainer.y) * (newScale / oldScale)
                    imgContainer.scaleVal = newScale
                }
                // 双击重置：恢复默认缩放和位置
                onDoubleClicked: {
                    imgContainer.scaleVal = 1.0
                    imgContainer.x = 0; imgContainer.y = 0
                }
            }
        }

        // 底部检测结果状态栏
        // 根据 verdict 值显示不同颜色：ok 为绿色，ng 为红色，其他为默认色
        Rectangle {
            id: statusBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 4
            height: 36
            radius: 6

            // 从脚本引擎获取当前检测结果
            property string verdict: (windowScriptEngine && windowScriptEngine.verdict)
                                     ? windowScriptEngine.verdict : ""

            // 背景色随检测结果变化：ok 绿色调，ng 红色调，默认暗色调
            color: {
                if (verdict === "ok") return "#1a3a2a"
                if (verdict === "ng") return "#3a1a1a"
                return "#1e1e32"
            }
            Behavior on color { ColorAnimation { duration: 300 } }

            // 边框颜色与背景色主题对应
            border.color: {
                if (verdict === "ok") return "#27ae60"
                if (verdict === "ng") return "#e74c3c"
                return "#2d2d45"
            }
            border.width: 1

            // 状态指示器和文本标签的布局
            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                // 状态圆点指示器，有结果时闪烁动画
                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: {
                        if (statusBar.verdict === "ok") return "#27ae60"
                        if (statusBar.verdict === "ng") return "#e74c3c"
                        return "#505068"
                    }

                    // 有检测结果时执行呼吸闪烁动画（透明度在 1.0 和 0.3 之间循环）
                    SequentialAnimation on opacity {
                        running: statusBar.verdict !== ""
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.3; duration: 600; easing.type: Easing.InOutSine }
                        NumberAnimation { from: 0.3; to: 1.0; duration: 600; easing.type: Easing.InOutSine }
                    }
                }

                // 结果文字标签：OK / NG / 待检测
                Label {
                    text: statusBar.verdict ? statusBar.verdict.toUpperCase() : "待检测"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: {
                        if (statusBar.verdict === "ok") return "#27ae60"
                        if (statusBar.verdict === "ng") return "#e74c3c"
                        return "#606078"
                    }
                    Behavior on color { ColorAnimation { duration: 300 } }
                }
            }

            // 检测结果变化时的脉冲缩放动画
            ScaleAnimator on scale {
                id: pulseAnim
                from: 1.0; to: 1.0
                duration: 200
                running: false
            }

            // 监听脚本引擎的 verdict 变化，触发脉冲动画
            Connections {
                target: windowScriptEngine
                function onVerdictChanged() {
                    pulseAnim.from = 1.03
                    pulseAnim.to = 1.0
                    pulseAnim.running = true
                }
            }
        }
    }

    // 右上角的配置按钮，点击打开算法参数设置对话框
    Rectangle {
        width: 32
        height: 32
        radius: 16
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        color: configHover.hovered ? "#0fabbc" : "#252540"
        Behavior on color { ColorAnimation { duration: 150 } }

        Label {
            anchors.centerIn: parent
            text: "⚙"
            font.pixelSize: 16
            color: configHover.hovered ? "#12121f" : "#9090a0"
        }

        MouseArea {
            id: configHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: algoDialog.open()
        }
    }

    // 算法参数配置对话框
    AlgoDialog {
        id: algoDialog
        scriptEngine: windowScriptEngine
        currentIndex: windowIndex
    }
}
