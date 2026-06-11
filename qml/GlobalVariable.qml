// 全局变量管理弹窗
// 提供全局变量的查看、添加、编辑、删除和保存功能
// 变量支持三种类型：string（字符串）、number（数字）、boolean（布尔值）
// 数据持久化到 GlobalVars.json 文件中

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Popup {
    id: root

    // 全局变量管理器实例，由外部注入
    property var globalVarMgr: null

    width: 560
    height: 500
    modal: true
    closePolicy: Popup.CloseOnEscape
    anchors.centerIn: Overlay.overlay
    padding: 0
    topPadding: 0

    // 变量列表的数据模型，存储每行的变量名、类型和值
    ListModel {
        id: varModel
    }

    // 从文件加载全局变量配置，并同步到数据模型中
    function loadVars() {
        if (!globalVarMgr) return
        var dir = FileConfig.scriptDir()
        var path = dir + "/GlobalVars.json"
        globalVarMgr.loadFromFile(path)
        syncFromManager()
    }

    // 从底层管理器同步变量数据到 UI 列表模型
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

    // 将 UI 中修改后的变量数据同步回底层管理器
    // 先移除所有旧变量，再重新添加，值会根据类型进行转换
    function syncToManager() {
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

    // 将当前变量保存到 JSON 文件
    // 先同步 UI 变更到管理器，再执行文件写入
    function saveVars() {
        if (!globalVarMgr) return
        syncToManager()
        var dir = FileConfig.scriptDir()
        var path = dir + "/GlobalVars.json"
        globalVarMgr.saveToFile(path)
    }

    // 弹窗打开时自动加载变量数据
    onOpened: {
        loadVars()
        Logger.setStatus("全局变量对话框已打开")
    }

    contentItem: Rectangle {
        color: "#1a1a2e"
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            // 标题：显示"全局变量"
            Label {
                text: "全局变量"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: "#e8e8f0"
            }

            // 表格头部：变量名、类型、值、操作列
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label { text: "变量名"; Layout.preferredWidth: 130; font.pixelSize: 11; font.weight: Font.DemiBold; color: "#707088" }
                Label { text: "类型"; Layout.preferredWidth: 90; font.pixelSize: 11; font.weight: Font.DemiBold; color: "#707088" }
                Label { text: "值"; Layout.fillWidth: true; font.pixelSize: 11; font.weight: Font.DemiBold; color: "#707088" }
                Item { Layout.preferredWidth: 40 }
            }

            // 表头与列表之间的分割线
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#252540"
            }

            // 变量列表区域，支持滚动
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    id: varColumn
                    width: parent.width
                    spacing: 6

                    // 使用 Repeater 动态生成每一行变量编辑控件
                    Repeater {
                        model: varModel
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            // 变量名输入框
                            TextField {
                                Layout.preferredWidth: 130
                                text: varName
                                font.pixelSize: 12
                                color: "#e0e0f0"
                                topPadding: 6; bottomPadding: 6; leftPadding: 8
                                background: Rectangle {
                                    color: "#0f0f1a"; radius: 4
                                    border.color: "#2d2d45"; border.width: 1
                                }
                                // 内容变化时同步更新数据模型
                                onTextChanged: varModel.setProperty(index, "varName", text)
                            }
                            // 类型下拉选择框，可选 string / number / boolean
                            ComboBox {
                                id: typeCombo
                                Layout.preferredWidth: 90
                                model: ["string", "number", "boolean"]
                                // 根据当前类型值设置选中索引
                                currentIndex: {
                                    if (varType === "number") return 1
                                    if (varType === "boolean") return 2
                                    return 0
                                }
                                font.pixelSize: 12
                                background: Rectangle {
                                    color: "#0f0f1a"; radius: 4
                                    border.color: "#2d2d45"; border.width: 1
                                }
                                contentItem: Label {
                                    text: typeCombo.currentText; font.pixelSize: 12; color: "#e0e0f0"
                                    verticalAlignment: Text.AlignVCenter; leftPadding: 8
                                }
                                // 类型变更时同步到数据模型
                                onCurrentTextChanged: varModel.setProperty(index, "varType", typeCombo.currentText)
                            }
                            // 变量值输入框
                            TextField {
                                Layout.fillWidth: true
                                text: varValue
                                font.pixelSize: 12
                                color: "#e0e0f0"
                                topPadding: 6; bottomPadding: 6; leftPadding: 8
                                background: Rectangle {
                                    color: "#0f0f1a"; radius: 4
                                    border.color: "#2d2d45"; border.width: 1
                                }
                                // 值变化时同步更新数据模型
                                onTextChanged: varModel.setProperty(index, "varValue", text)
                            }
                            // 删除按钮：从管理器和列表中移除当前变量
                            Rectangle {
                                Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 4
                                color: delHover.hovered ? "#e74c3c" : "transparent"
                                Behavior on color { ColorAnimation { duration: 150 } }

                                Label {
                                    anchors.centerIn: parent; text: "✕"; font.pixelSize: 14
                                    color: delHover.hovered ? "#ffffff" : "#9090a0"
                                }
                                MouseArea {
                                    id: delHover; anchors.fill: parent; hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        globalVarMgr.removeVariable(origName)
                                        varModel.remove(index)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // 底部操作栏与列表之间的分割线
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#252540"
            }

            // 底部操作栏：添加变量、保存、取消
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // "添加变量"按钮：在列表末尾追加一个默认的数字类型变量
                Rectangle {
                    Layout.preferredHeight: 32; Layout.preferredWidth: 100; radius: 4
                    color: addHover.hovered ? Qt.lighter("#27ae60", 1.15) : "#1a3a2a"
                    border.color: "#27ae60"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Label {
                        anchors.centerIn: parent; text: "+ 添加变量"; font.pixelSize: 11
                        font.weight: Font.DemiBold; color: "#27ae60"
                    }
                    MouseArea {
                        id: addHover; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            varModel.append({
                                origName: "var" + (varModel.count + 1),
                                varName: "var" + (varModel.count + 1),
                                varType: "number",
                                varValue: "0"
                            })
                        }
                    }
                }

                // 弹性空间，将保存和取消按钮推到右侧
                Item { Layout.fillWidth: true }

                // "保存"按钮：保存变量到文件并关闭弹窗
                Rectangle {
                    Layout.preferredHeight: 32; Layout.preferredWidth: 64; radius: 4
                    color: saveBtnHover.hovered ? Qt.lighter("#0fabbc", 1.15) : "#0fabbc"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Label {
                        anchors.centerIn: parent; text: "保存"; font.pixelSize: 11
                        font.weight: Font.DemiBold; color: "#12121f"
                    }
                    MouseArea {
                        id: saveBtnHover; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { root.saveVars(); root.close() }
                    }
                }

                // "取消"按钮：关闭弹窗不保存
                Rectangle {
                    Layout.preferredHeight: 32; Layout.preferredWidth: 64; radius: 4
                    color: cancelHover.hovered ? "#252540" : "transparent"
                    border.color: "#2d2d45"; border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Label {
                        anchors.centerIn: parent; text: "取消"; font.pixelSize: 11
                        font.weight: Font.DemiBold; color: "#9090a0"
                    }
                    MouseArea {
                        id: cancelHover; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.close()
                    }
                }
            }
        }
    }
}
