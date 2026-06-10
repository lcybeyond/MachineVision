import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import com.lcy.algorithmManager

Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    width: Overlay.overlay.width * 0.6
    height: Overlay.overlay.height * 0.8
    focus: true
    closePolicy: Popup.CloseOnEscape
    modal: true
    padding: 0
    property int currentIndex: 0
    property var scriptEngine: null
    property string fileName: ""

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
    }

    property string defaultCode: ``

    contentItem: Rectangle {
        color: "#1e1e1e"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ======== 顶部：文件名 + 保存 + 关闭 ========
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: "#2d2d2d"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    TextField {
                        id: fileNameField
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 160
                        text: root.fileName
                        color: "#d4d4d4"
                        font.pixelSize: 12
                        font.family: "Menlo"
                        topPadding: 4
                        bottomPadding: 4
                        leftPadding: 8
                        background: Rectangle {
                            color: "#3c3c3c"
                            radius: 3
                            border.color: "#555555"
                            border.width: 1
                        }
                    }

                    Button {
                        Layout.preferredHeight: 36
                        text: "保存"
                        font.pixelSize: 12
                        Material.background: "#0e639c"
                        Material.foreground: "#ffffff"
                        onClicked: {
                            root.fileName = fileNameField.text
                            var key = "Algo" + root.currentIndex
                            FileConfig.saveSetting(key, root.fileName)
                            var path = FileConfig.scriptDir() + "/" + root.fileName
                            FileConfig.writeFile(path, codeEdit.text)
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 30
                        text: "✕"
                        font.pixelSize: 14
                        flat: true
                        Material.foreground: "#cccccc"
                        onClicked: root.close()
                    }
                }
            }

            // ======== 中间：代码编辑区 ========
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                TextEdit {
                    id: codeEdit
                    width: scrollView.availableWidth
                    height: Math.max(scrollView.availableHeight, contentHeight)
                    leftPadding: 16
                    topPadding: 12
                    color: "#d4d4d4"
                    font.family: "Menlo"
                    font.pixelSize: 13
                    text: root.defaultCode
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

            // ======== 底部：执行 + 停止 ========
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#2d2d2d"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Button {
                        text: "执行"
                        font.pixelSize: 14
                        Material.background: "#0e639c"
                        Material.foreground: "#ffffff"
                        onClicked: {
                            if (root.scriptEngine)
                                root.scriptEngine.evaluate(codeEdit.text)
                        }
                    }

                    Button {
                        text: "停止"
                        font.pixelSize: 14
                        Material.background: "#5a1d1d"
                        Material.foreground: "#f48771"
                        onClicked: {
                            if (root.scriptEngine)
                                root.scriptEngine.stop()
                        }
                    }
                }
            }
        }
    }
}
