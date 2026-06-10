import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root

    signal modifyScriptMgr(int index)

    property int columns: 3
    property int windowCount: 6
    property real rowSpacing: 15
    property real columnSpacing: 15
    property var scriptMgr: null
    property var fileEngine: null
    property var logger: null

    function executeAll() {
        if (!scriptMgr || !fileEngine) return
        logText.text = ""
        if (logger) logger.clear()
        for (var i = 0; i < windowCount; i++) {
            var key = "Algo" + i
            var fileName = fileEngine.loadSetting(key)
            if (fileName === "") continue
            var code = fileEngine.readFile(fileEngine.scriptDir() + "/" + fileName)
            if (code === "") continue
            var engine = scriptMgr.engineAt(i)
            if (!engine) continue
            engine.setLogPrefix("窗口" + (i + 1))
            engine.evaluate(code)
        }
    }

    function stopAll() {
        if (!scriptMgr) return
        for (var i = 0; i < windowCount; i++) {
            var engine = scriptMgr.engineAt(i)
            if (engine) engine.stop()
        }
    }

    RowLayout {
        anchors.margins: 10
        anchors.fill: parent
        spacing: 10

        GridLayout {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true

            columns: root.columns
            rowSpacing: root.rowSpacing
            columnSpacing: root.columnSpacing

            Repeater {
                id: repeater
                model: root.windowCount
                ImageWindow {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    windowIndex: index
                }
                Component.onCompleted: {
                    scriptMgr.ensureCount(repeater.count + 1)
                    for (var i = 0; i < repeater.count; i++) {
                        repeater.itemAt(i).windowScriptEngine = scriptMgr.engineAt(i)
                    }
                    modifyScriptMgr(repeater.count)
                }
                onCountChanged: {
                    scriptMgr.ensureCount(repeater.count + 1)
                    for (var i = 0; i < repeater.count; i++) {
                        repeater.itemAt(i).windowScriptEngine = scriptMgr.engineAt(i)
                    }
                    modifyScriptMgr(repeater.count)
                }
            }
        }

        // 右侧控制面板
        Rectangle {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: "#fafafa"
            border.color: "#e0e0e0"
            border.width: 1
            radius: 4

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // 执行 / 停止按钮
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: "执行"
                        font.pixelSize: 14
                        Material.background: "#27ae60"
                        Material.foreground: "#ffffff"
                        onClicked: root.executeAll()
                    }
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: "停止"
                        font.pixelSize: 14
                        Material.background: "#e74c3c"
                        Material.foreground: "#ffffff"
                        onClicked: root.stopAll()
                    }
                }

                // 日志区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#1e1e1e"
                    radius: 4

                    Flickable {
                        id: logFlick
                        anchors.fill: parent
                        anchors.margins: 4
                        contentHeight: logText.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        TextEdit {
                            id: logText
                            width: logFlick.width
                            readOnly: true
                            color: "#d4d4d4"
                            font.pixelSize: 12
                            font.family: "Menlo, Consolas, monospace"
                            text: ""
                            wrapMode: TextEdit.Wrap
                        }
                    }

                    Connections {
                        target: logger
                        function onNewLog(msg) {
                            logText.text += msg + "\n"
                            Qt.callLater(function() {
                                logFlick.contentY = logText.implicitHeight - logFlick.height
                            })
                        }
                    }
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    text: "清空日志"
                    font.pixelSize: 12
                    onClicked: {
                        if (logger) logger.clear()
                        logText.clear()
                    }
                }
            }
        }
    }
}
