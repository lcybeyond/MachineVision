import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Popup {
    id: root

    property var globalVarMgr: null

    width: 540
    height: 480
    modal: true
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: Overlay.overlay
    padding: 20

    ListModel {
        id: varModel
    }

    function loadVars() {
        if (!globalVarMgr) return
        var dir = FileConfig.scriptDir()
        var path = dir + "/GlobalVars.json"
        globalVarMgr.loadFromFile(path)
        syncFromManager()
    }

    function syncFromManager() {
        varModel.clear()
        var vars = globalVarMgr.variables
        for (var i = 0; i < vars.length; i++) {
            varModel.append({
                origName: vars[i].name,
                varName: vars[i].name,
                varType: vars[i].type,
                varValue: String(vars[i].value !== undefined ? vars[i].value : "")
            })
        }
    }

    function syncToManager() {
        // 先全部删除，再重新添加
        for (var i = 0; i < varModel.count; i++) {
            var item = varModel.get(i)
            globalVarMgr.removeVariable(item.origName)
        }
        for (var j = 0; j < varModel.count; j++) {
            var item2 = varModel.get(j)
            var val
            if (item2.varType === "number") val = Number(item2.varValue)
            else if (item2.varType === "boolean") val = (item2.varValue === "true" || item2.varValue === "1")
            else val = item2.varValue
            globalVarMgr.addVariable(item2.varName, item2.varType, val)
            varModel.setProperty(j, "origName", item2.varName)
        }
    }

    function saveVars() {
        if (!globalVarMgr) return
        syncToManager()
        var dir = FileConfig.scriptDir()
        var path = dir + "/GlobalVars.json"
        globalVarMgr.saveToFile(path)
    }

    onOpened: loadVars()

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Label {
            text: "全局变量"
            font.pixelSize: 18
            font.bold: true
        }

        // 表头
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Label { text: "变量名"; Layout.preferredWidth: 130; font.pixelSize: 12; font.bold: true }
            Label { text: "类型"; Layout.preferredWidth: 90; font.pixelSize: 12; font.bold: true }
            Label { text: "值"; Layout.fillWidth: true; font.pixelSize: 12; font.bold: true }
            Item { Layout.preferredWidth: 40 }
        }

        // 变量列表（可滚动）
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                id: varColumn
                width: parent.width
                spacing: 6

                Repeater {
                    model: varModel
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        TextField {
                            Layout.preferredWidth: 130
                            text: varName
                            font.pixelSize: 13
                            onTextChanged: varModel.setProperty(index, "varName", text)
                        }
                        ComboBox {
                            Layout.preferredWidth: 90
                            model: ["string", "number", "boolean"]
                            currentIndex: {
                                if (varType === "number") return 1
                                if (varType === "boolean") return 2
                                return 0
                            }
                            font.pixelSize: 13
                            onCurrentTextChanged: varModel.setProperty(index, "varType", currentText)
                        }
                        TextField {
                            Layout.fillWidth: true
                            text: varValue
                            font.pixelSize: 13
                            onTextChanged: varModel.setProperty(index, "varValue", text)
                        }
                        Button {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            text: "✕"
                            font.pixelSize: 14
                            Material.background: "#e74c3c"
                            Material.foreground: "#ffffff"
                            onClicked: {
                                globalVarMgr.removeVariable(origName)
                                varModel.remove(index)
                            }
                        }
                    }
                }
            }
        }

        // 底部操作栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Button {
                text: "+ 添加变量"
                font.pixelSize: 13
                Material.background: "#27ae60"
                Material.foreground: "#ffffff"
                onClicked: {
                    varModel.append({
                        origName: "var" + (varModel.count + 1),
                        varName: "var" + (varModel.count + 1),
                        varType: "number",
                        varValue: "0"
                    })
                }
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "保存"
                font.pixelSize: 13
                Material.background: "#0e639c"
                Material.foreground: "#ffffff"
                onClicked: {
                    root.saveVars()
                    root.close()
                }
            }

            Button {
                text: "取消"
                font.pixelSize: 13
                onClicked: root.close()
            }
        }
    }
}
