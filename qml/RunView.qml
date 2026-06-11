// 运行视图
// 显示图像窗口的网格布局和右侧控制面板
// 支持批量执行所有窗口的脚本（executeAll）和批量停止（stopAll）
// 右侧面板包含执行/停止按钮和实时日志输出区域
// 网格布局的列数、窗口数、行间距和列间距由外部属性动态控制

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Item {
    id: root

    // 当窗口数量发生变化时发出此信号，通知外部更新脚本引擎引用
    signal modifyScriptMgr(int index)

    // 网格布局列数，由布局设置或外部调用者控制
    property int columns: 3
    // 图像窗口总数，由布局设置或外部调用者控制
    property int windowCount: 6
    // 行间距，单位像素
    property real rowSpacing: 15
    // 列间距，单位像素
    property real columnSpacing: 15
    // 脚本管理器实例，管理所有窗口的脚本引擎
    property var scriptMgr: null

    // 组件初始化完成时记录日志
    Component.onCompleted: Logger.setStatus("运行视图初始化完成")

    // 执行全部窗口的算法脚本
    // 遍历所有窗口，读取每个窗口关联的脚本文件并执行
    function executeAll() {
        if (!scriptMgr) return
        logText.text = ""
        Logger.clear()
        for (var i = 0; i < windowCount; i++) {
            var key = "Algo" + i
            var fileName = FileConfig.loadSetting(key)
            if (fileName === "") continue
            var code = FileConfig.readFile(FileConfig.scriptDir() + "/" + fileName)
            if (code === "") continue
            var engine = scriptMgr.engineAt(i)
            if (!engine) continue
            engine.setLogPrefix("窗口" + (i + 1))
            engine.evaluate(code)
        }
    }

    // 停止全部窗口正在运行的脚本
    function stopAll() {
        if (!scriptMgr) return
        for (var i = 0; i < windowCount; i++) {
            var engine = scriptMgr.engineAt(i)
            if (engine) engine.stop()
        }
    }

    // 主布局：左侧为图像窗口网格，右侧为控制面板
    RowLayout {
        anchors.margins: 8
        anchors.fill: parent
        spacing: 8

        // 图像窗口网格布局
        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true

            // 网格列数和间距由外部属性绑定
            columns: root.columns
            rowSpacing: root.rowSpacing
            columnSpacing: root.columnSpacing

            // 使用 Repeater 动态生成指定数量的 ImageWindow 实例
            Repeater {
                id: repeater
                model: root.windowCount
                ImageWindow {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    windowIndex: index
                }

                // 当窗口数量变化时，确保脚本管理器中有足够多的引擎实例
                // 并将每个引擎绑定到对应的图像窗口
                onCountChanged: {
                    if (count > 0) {
                        Qt.callLater(function() {
                            scriptMgr.ensureCount(repeater.count + 1)
                            for (var i = 0; i < repeater.count; i++) {
                                repeater.itemAt(i).windowScriptEngine = scriptMgr.engineAt(i)
                            }
                            modifyScriptMgr(repeater.count)
                        })
                    }
                }
            }
        }

        // 右侧控制面板
        Rectangle {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: "#1a1a2e"
            radius: 8
            border.color: "#252540"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // 面板标题
                Label {
                    text: "控制面板"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: "#9090a0"
                    Layout.bottomMargin: 2
                }

                // 执行和停止按钮行
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // "执行全部"按钮：触发所有窗口脚本的执行
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 6
                        color: execHover.hovered ? "#219a5a" : "#1a3a2a"
                        border.color: "#27ae60"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent
                            text: "▶  执行全部"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: "#27ae60"
                        }

                        MouseArea {
                            id: execHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.executeAll()

                            // 按下时缩小按钮产生点击反馈
                            onPressed: parent.scale = 0.97
                            onReleased: parent.scale = 1.0
                        }
                    }

                    // "停止全部"按钮：停止所有窗口的运行中脚本
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 6
                        color: stopHover.hovered ? "#c0392b" : "#2a1a1a"
                        border.color: "#e74c3c"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent
                            text: "■  停止全部"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: "#e74c3c"
                        }

                        MouseArea {
                            id: stopHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.stopAll()

                            // 按下时缩小按钮产生点击反馈
                            onPressed: parent.scale = 0.97
                            onReleased: parent.scale = 1.0
                        }
                    }
                }

                // 按钮区与日志区之间的分割线
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#252540"
                }

                // 日志输出区域头部：标题和清空按钮
                RowLayout {
                    Layout.fillWidth: true

                    Label {
                        text: "日志输出"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        color: "#707088"
                        Layout.fillWidth: true
                    }

                    // "清空"按钮：清除 Logger 和日志显示区域的内容
                    Rectangle {
                        Layout.preferredWidth: 60
                        Layout.preferredHeight: 22
                        radius: 4
                        color: clearHover.hovered ? "#2d2d45" : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent
                            text: "清空"
                            font.pixelSize: 10
                            color: "#707088"
                        }

                        MouseArea {
                            id: clearHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Logger.clear()
                                logText.clear()
                            }
                        }
                    }
                }

                // 日志输出区域，使用 Flickable + TextEdit 实现
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#0f0f1a"
                    radius: 6
                    border.color: "#1e1e32"
                    border.width: 1

                    // 可滚动容器，内容超出时支持触摸滚动
                    Flickable {
                        id: logFlick
                        anchors.fill: parent
                        anchors.margins: 6
                        contentHeight: logText.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        // 只读的多行文本编辑区，用于显示日志，使用等宽字体
                        TextEdit {
                            id: logText
                            width: logFlick.width
                            readOnly: true
                            color: "#c0c0d0"
                            font.pixelSize: 11
                            font.family: "Menlo, Consolas, monospace"
                            text: ""
                            wrapMode: TextEdit.Wrap
                            selectionColor: "#264f78"
                        }
                    }

                    // 监听 Logger 的新日志信号，追加到日志显示区域
                    // 新日志到达后自动滚动到底部
                    Connections {
                        target: Logger
                        function onNewLog(msg) {
                            logText.text += msg + "\n"
                            Qt.callLater(function() {
                                logFlick.contentY = logText.implicitHeight - logFlick.height
                            })
                        }
                    }

                    // 自定义滚动条指示器，显示当前滚动位置
                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 2
                        width: 3
                        radius: 1.5
                        color: "#2d2d45"
                        // 根据 Flickable 的可见区域比例计算滚动条位置和高度
                        y: logFlick.visibleArea.yPosition * parent.height
                        height: logFlick.visibleArea.heightRatio * parent.height
                        // 仅当内容超出可视区域时才显示滚动条
                        visible: logFlick.contentHeight > logFlick.height
                        opacity: 0.6
                    }
                }
            }
        }
    }
}
