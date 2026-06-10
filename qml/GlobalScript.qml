import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

Item {

    id: root

    property var scriptEngine: null
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // ======== 工具栏 ========
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: "#2d2d2d"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 4

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    Layout.fillHeight: true
                    text: "应用"
                    flat: true
                    font.pixelSize: 16
                    Material.foreground: "#4ec9b0"
                    onClicked: root.close()
                }
            }
        }

        // ======== 代码编辑区 ========
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            contentWidth: editorRow.width
            contentHeight: editorRow.height

            Row {
                id: editorRow
                height: codeEdit.contentHeight

                // -- 行号栏 --
                Rectangle {
                    id: gutter
                    width: 48
                    height: codeEdit.contentHeight
                    color: "#1e1e1e"

                    Column {
                        anchors.right: parent.right
                        anchors.rightMargin: 8

                        Repeater {
                            model: Math.max(codeEdit.lineCount, 1)

                            Label {
                                width: 36
                                height: 20
                                text: index + 1
                                color: "#858585"
                                font.family: "Menlo"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // -- 分隔线 --
                Rectangle {
                    width: 1
                    height: codeEdit.contentHeight
                    color: "#3c3c3c"
                }

                // -- 代码编辑 --
                TextEdit {
                    id: codeEdit
                    width: Math.max(scrollView.availableWidth - 49,
                                    contentWidth + 32)
                    height: contentHeight
                    leftPadding: 16
                    color: "#d4d4d4"
                    font.family: "Menlo"
                    font.pixelSize: 13
                    text: ""
                    tabStopDistance: 32
                    selectByMouse: true
                    persistentSelection: true
                    wrapMode: TextEdit.NoWrap
                    selectionColor: "#264f78"
                    selectedTextColor: "#ffffff"
                    cursorVisible: true
                    activeFocusOnPress: true
                }

                Button {
                    text: "执行"
                    onClicked: {
                        if (scriptEngine)
                            scriptEngine.evaluate(codeEdit.text);
                    }
                }
            }
        }
    }

}
