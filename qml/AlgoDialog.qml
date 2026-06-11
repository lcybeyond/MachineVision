import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import com.lcy.algorithmManager

// 算法脚本编辑对话框 —— 以弹窗形式提供算法脚本的编辑、保存和执行功能
// 支持加载/保存脚本文件，内置代码编辑器，可运行和停止脚本
Popup {
    id: root
    // 弹窗居中显示，尺寸为覆盖层的 60% 宽、80% 高
    anchors.centerIn: Overlay.overlay
    width: Overlay.overlay.width * 0.6
    height: Overlay.overlay.height * 0.8
    focus: true
    // 按 ESC 键可关闭弹窗
    closePolicy: Popup.CloseOnEscape
    // 模态弹窗，阻止与背景交互
    modal: true
    padding: 0
    // 当前算法索引，对应 Algo0~AlgoN 的配置键
    property int currentIndex: 0
    // 脚本引擎对象，用于执行和停止 JavaScript 脚本
    property var scriptEngine: null
    // 当前编辑的脚本文件名
    property string fileName: ""

    // 弹窗打开时加载已保存的脚本配置或使用默认文件名
    onOpened: {
        var key = "Algo" + currentIndex
        var saved = FileConfig.loadSetting(key)

        if (saved !== "") {
            fileName = saved
            defaultCode = FileConfig.readFile(FileConfig.scriptDir() + "/" + fileName)
        } else {
            fileName = "algo" + currentIndex + ".js"
            FileConfig.saveSetting(key, fileName)
        }
        Logger.setStatus("算法对话框" + (currentIndex + 1) + "已打开")
    }

    // 默认脚本代码内容，在弹窗打开时从文件加载
    property string defaultCode: ``

    // 弹窗内容区域
    contentItem: Rectangle {
        color: "#1a1a2e"
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // 顶部工具栏：文件名输入框 + 保存按钮 + 关闭按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#0f0f1a"
                radius: 8

                // 底部边框分隔线
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: "#252540"
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 8

                    // 脚本文件名输入框，可手动修改文件名
                    TextField {
                        id: fileNameField
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 160
                        text: root.fileName
                        color: "#e0e0f0"
                        font.pixelSize: 12
                        font.family: "Menlo"
                        topPadding: 4
                        bottomPadding: 4
                        leftPadding: 8
                        background: Rectangle {
                            color: "#1a1a2e"
                            radius: 4
                            border.color: "#2d2d45"
                            border.width: 1
                        }
                    }

                    // 保存按钮 —— 将当前代码写入文件并更新配置
                    Rectangle {
                        Layout.preferredHeight: 28; Layout.preferredWidth: 52; radius: 4
                        // 悬停时高亮颜色
                        color: saveHover.hovered ? Qt.lighter("#0fabbc", 1.15) : "#0fabbc"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent; text: "保存"; font.pixelSize: 11
                            font.weight: Font.DemiBold; color: "#12121f"
                        }
                        MouseArea {
                            id: saveHover; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            // 点击时保存文件名到配置，并将编辑器内容写入脚本文件
                            onClicked: {
                                root.fileName = fileNameField.text
                                var key = "Algo" + root.currentIndex
                                FileConfig.saveSetting(key, root.fileName)
                                var path = FileConfig.scriptDir() + "/" + root.fileName
                                FileConfig.writeFile(path, codeEdit.text)
                            }
                        }
                    }

                    // 弹性空白占位，将后续控件推到右侧
                    Item { Layout.fillWidth: true }

                    // 关闭按钮 —— 关闭算法编辑弹窗
                    Rectangle {
                        Layout.preferredHeight: 28; Layout.preferredWidth: 28; radius: 4
                        // 悬停时变为红色警告色
                        color: closeHover.hovered ? "#e74c3c" : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent; text: "✕"; font.pixelSize: 14
                            color: closeHover.hovered ? "#ffffff" : "#9090a0"
                        }
                        MouseArea {
                            id: closeHover; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.close()
                        }
                    }
                }
            }

            // 代码编辑器区域 —— 支持滚动、多行编辑的文本编辑器
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // 文本编辑器，等宽字体，支持鼠标选中等标准编辑功能
                TextEdit {
                    id: codeEdit
                    width: scrollView.availableWidth
                    // 高度至少为可用区域高度，保证可以滚动到内容末尾
                    height: Math.max(scrollView.availableHeight, contentHeight)
                    leftPadding: 16
                    topPadding: 12
                    color: "#d4d4d4"
                    font.family: "Menlo"
                    font.pixelSize: 13
                    text: root.defaultCode
                    // Tab 键缩进距离
                    tabStopDistance: 32
                    selectByMouse: true
                    persistentSelection: true
                    wrapMode: TextEdit.NoWrap
                    selectionColor: "#264f78"
                    selectedTextColor: "#ffffff"
                    cursorVisible: true
                    activeFocusOnPress: true
                }
            }

            // 底部操作栏：执行按钮 + 停止按钮
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                color: "#0f0f1a"

                // 顶部边框分隔线
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: 1
                    color: "#252540"
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 12

                    // 执行按钮 —— 调用脚本引擎执行当前编辑器中的代码
                    Rectangle {
                        Layout.preferredHeight: 30; Layout.preferredWidth: 72; radius: 4
                        // 悬停时绿色高亮
                        color: runHover.hovered ? Qt.lighter("#27ae60", 1.15) : "#1a3a2a"
                        border.color: "#27ae60"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent; text: "▶ 执行"; font.pixelSize: 12
                            font.weight: Font.DemiBold; color: "#27ae60"
                        }
                        MouseArea {
                            id: runHover; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.scriptEngine)
                                    root.scriptEngine.evaluate(codeEdit.text)
                            }
                            // 按下时缩放效果，提供触觉反馈
                            onPressed: parent.scale = 0.95
                            onReleased: parent.scale = 1.0
                        }
                    }

                    // 停止按钮 —— 终止脚本引擎中正在运行的脚本
                    Rectangle {
                        Layout.preferredHeight: 30; Layout.preferredWidth: 72; radius: 4
                        // 悬停时红色高亮
                        color: stopHover.hovered ? Qt.lighter("#e74c3c", 1.15) : "#2a1a1a"
                        border.color: "#e74c3c"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Label {
                            anchors.centerIn: parent; text: "■ 停止"; font.pixelSize: 12
                            font.weight: Font.DemiBold; color: "#e74c3c"
                        }
                        MouseArea {
                            id: stopHover; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.scriptEngine)
                                    root.scriptEngine.stop()
                            }
                            // 按下时缩放效果，提供触觉反馈
                            onPressed: parent.scale = 0.95
                            onReleased: parent.scale = 1.0
                        }
                    }
                }
            }
        }
    }
}
