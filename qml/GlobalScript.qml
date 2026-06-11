import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import com.lcy.algorithmManager

// 全局脚本编辑器 —— 提供一个带行号的代码编辑器，用于编写和执行全局 JavaScript 脚本
// 包含工具栏（标题 + 执行按钮）和代码编辑区域（行号侧栏 + 编辑器主体）
Item {
    id: root

    // 脚本引擎对象，用于执行编辑器中的 JavaScript 代码
    property var scriptEngine: null

    // 组件初始化完成，记录日志
    Component.onCompleted: Logger.setStatus("全局脚本初始化完成")

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部工具栏：标题 + 执行按钮
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: "#1a1a2e"

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
                anchors.rightMargin: 12
                spacing: 8

                // 工具栏标题
                Label {
                    text: "全局脚本"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: "#707088"
                }

                // 弹性占位，将按钮推到右侧
                Item { Layout.fillWidth: true }

                // 执行按钮 —— 调用脚本引擎执行编辑器中的全局脚本代码
                Rectangle {
                    Layout.preferredHeight: 26; Layout.preferredWidth: 64; radius: 4
                    // 悬停时绿色高亮
                    color: execHover.hovered ? Qt.lighter("#27ae60", 1.15) : "#1a3a2a"
                    border.color: "#27ae60"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Label {
                        anchors.centerIn: parent; text: "▶ 执行"; font.pixelSize: 11
                        font.weight: Font.DemiBold; color: "#27ae60"
                    }
                    MouseArea {
                        id: execHover; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (scriptEngine)
                                scriptEngine.evaluate(codeEdit.text)
                        }
                        // 按下时缩放效果，提供触觉反馈
                        onPressed: parent.scale = 0.95
                        onReleased: parent.scale = 1.0
                    }
                }
            }
        }

        // 代码编辑区域 —— 包含行号侧栏和编辑器主体的滚动视图
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // 内容尺寸由编辑器行组件决定
            contentWidth: editorRow.width
            contentHeight: editorRow.height

            // 编辑器行组件：行号侧栏 + 分隔线 + 代码编辑器
            Row {
                id: editorRow
                height: codeEdit.contentHeight

                // 行号侧栏 —— 显示每一行的行号（1-based）
                Rectangle {
                    id: gutter
                    width: 48
                    height: codeEdit.contentHeight
                    color: "#0f0f1a"

                    Column {
                        anchors.right: parent.right
                        anchors.rightMargin: 8

                        // 使用 Repeater 根据代码行数动态生成行号标签
                        Repeater {
                            model: Math.max(codeEdit.lineCount, 1)

                            Label {
                                width: 36
                                height: 20
                                text: index + 1
                                color: "#505068"
                                font.family: "Menlo"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // 行号与编辑器之间的分隔线
                Rectangle {
                    width: 1
                    height: codeEdit.contentHeight
                    color: "#252540"
                }

                // 代码编辑器主体 —— 多行纯文本编辑器，支持等宽字体、Tab 缩进和鼠标选中
                TextEdit {
                    id: codeEdit
                    // 宽度取可用宽度减去行号栏宽度与较大值（至少包含右侧 32px 内边距）
                    width: Math.max(scrollView.availableWidth - 49,
                                    contentWidth + 32)
                    height: contentHeight
                    leftPadding: 16
                    color: "#d4d4d4"
                    font.family: "Menlo"
                    font.pixelSize: 13
                    text: ""
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
        }
    }
}
