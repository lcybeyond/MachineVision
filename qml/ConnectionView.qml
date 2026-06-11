import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

// 连接管理视图 —— 管理所有连接配置的列表和详情面板
// 左侧为连接列表侧边栏，右侧为连接配置面板或空状态提示
// 支持新建、选择和切换连接配置
Item {
    id: root

    // 连接管理器对象，从外部传入，用于创建和管理连接实例
    property var connMgr: null
    // 当前选中的连接索引，-1 表示未选中
    property int selectedIndex: -1

    // 连接列表数据模型，存储每个连接的文件名、显示名称和参数
    ListModel { id: connListModel }

    // 从磁盘加载所有已保存的连接配置，创建连接实例并自动连接标记为 autoConnect 的连接
    function loadAllConnections() {
        connListModel.clear()
        var dirPath = FileConfig.connDir()
        var files = FileConfig.listFiles(dirPath)
        if (!files || files.length === 0) return

        var entries = []
        // 遍历配置目录下的所有 JSON 文件
        for (var i = 0; i < files.length; i++) {
            if (!/\.json$/i.test(files[i])) continue
            var path = dirPath + "/" + files[i]
            var jsonStr = FileConfig.readFile(path)
            if (jsonStr === "") continue
            var params = {}
            try { params = JSON.parse(jsonStr) } catch (e) { continue }
            if (!params || Array.isArray(params) || !params.type) continue

            entries.push({
                fileName: files[i],
                displayName: files[i].replace(/\.json$/i, ""),
                paramsJson: jsonStr,
                params: params,
                createdAt: params.createdAt || 0
            })
        }

        // 按创建时间升序排列
        entries.sort(function(a, b) { return a.createdAt - b.createdAt })

        // 将排序后的连接条目添加到列表模型，并为每个连接创建连接实例
        for (var j = 0; j < entries.length; j++) {
            var e = entries[j]
            connListModel.append({
                fileName: e.fileName,
                displayName: e.displayName,
                paramsJson: e.paramsJson
            })

            if (connMgr) {
                connMgr.createConnection(e.displayName, e.params.type, e.params)
                // 如果配置了自动连接，则立即建立连接
                if (e.params.autoConnect === true) {
                    var conn = connMgr.connection(e.displayName)
                    if (conn) conn.connect()
                }
            }
        }
    }

    // 选中一个连接，加载其配置到右侧面板
    function selectConnection(index) {
        selectedIndex = index
        var item = connListModel.get(index)
        connectionSettings.connectionIndex = index
        connectionSettings.fileName = item.fileName
        connectionSettings.loadParams(JSON.parse(item.paramsJson))
        stackLayout.currentIndex = 0
    }

    // 新建一个空白连接配置，使用默认参数
    function addNewConnection() {
        selectedIndex = -1
        var nextNum = connListModel.count + 1
        var defaultName = "conn" + nextNum + ".json"

        connListModel.append({
            fileName: defaultName,
            displayName: "conn" + nextNum,
            paramsJson: "{}"
        })

        connectionSettings.connectionIndex = connListModel.count - 1
        connectionSettings.fileName = defaultName
        connectionSettings.resetParams()
        stackLayout.currentIndex = 0
    }

    // 组件初始化完成，加载所有连接配置并记录日志
    Component.onCompleted: {
        loadAllConnections()
        Logger.setStatus("连接视图初始化完成")
    }

    // 左右分栏布局：左侧连接列表 + 右侧详情面板
    RowLayout {
        anchors.margins: 8
        anchors.fill: parent
        spacing: 8

        // 左侧边栏 —— 连接列表
        Rectangle {
            Layout.preferredWidth: 200
            Layout.fillHeight: true
            color: "#1a1a2e"
            radius: 8
            border.color: "#252540"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                // 侧边栏标题
                Label {
                    text: "连接列表"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: "#707088"
                    Layout.bottomMargin: 4
                    Layout.leftMargin: 8
                }

                // 连接列表 —— 每个条目显示类型图标、名称和连接状态指示灯
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: connListModel
                    clip: true
                    spacing: 3

                    // 列表项委托：显示连接类型图标、名称和连接状态点
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 38
                        radius: 6
                        // 选中时青色背景，悬停时浅色背景，否则透明
                        color: {
                            if (root.selectedIndex === index) return "#0fabbc"
                            if (itemHover.hovered) return "#252540"
                            return "transparent"
                        }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 8
                            spacing: 6

                            // 连接类型图标 —— 根据参数 JSON 中的 type 字段显示对应图标
                            Label {
                                text: {
                                    var p = {}
                                    try { p = JSON.parse(paramsJson) } catch (e) {}
                                    if (p.type === "camera") return "📷"
                                    if (p.type === "serial") return "🔌"
                                    return "🌐"
                                }
                                font.pixelSize: 12
                            }

                            // 连接名称，过长时右侧省略
                            Label {
                                Layout.fillWidth: true
                                text: displayName
                                font.pixelSize: 12
                                color: root.selectedIndex === index ? "#ffffff" : "#c0c0d0"
                                font.weight: root.selectedIndex === index ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                            }

                            // 连接状态指示灯 —— 绿色表示已连接，灰色表示未连接
                            Rectangle {
                                width: 6; height: 6; radius: 3
                                color: {
                                    var conn = connMgr ? connMgr.connection(displayName) : null
                                    return (conn && conn.connected) ? "#27ae60" : "#505068"
                                }
                            }
                        }

                        MouseArea {
                            id: itemHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            // 点击选中此连接
                            onClicked: root.selectConnection(index)
                        }
                    }
                }

                // 新建连接按钮
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 6
                    color: addHover.hovered ? "#1a3a2a" : "transparent"
                    border.color: "#252540"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Label {
                        anchors.centerIn: parent
                        text: "+ 新建连接"
                        font.pixelSize: 12
                        color: "#27ae60"
                    }

                    MouseArea {
                        id: addHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.addNewConnection()
                    }
                }
            }
        }

        // 右侧面板 —— 使用 StackLayout 在配置面板和空状态之间切换
        StackLayout {
            id: stackLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            // 默认显示空状态页
            currentIndex: 1

            // 连接配置面板（页面 0）
            ConnectionSetting {
                id: connectionSettings
                connMgr: root.connMgr
                Layout.fillWidth: true
                Layout.fillHeight: true

                // 当连接保存成功后，更新列表模型中的对应条目
                onSaved: (index, fileName, paramsJson) => {
                    if (index >= 0 && index < connListModel.count) {
                        connListModel.setProperty(index, "fileName", fileName)
                        connListModel.setProperty(index, "displayName", fileName.replace(/\.json$/i, ""))
                        connListModel.setProperty(index, "paramsJson", paramsJson)
                    }
                    root.selectedIndex = index
                }

                // 当连接删除成功后，从列表模型中移除并切换到空状态
                onDeleted: (index) => {
                    if (index >= 0 && index < connListModel.count) {
                        connListModel.remove(index)
                    }
                    root.selectedIndex = -1
                    connectionSettings.resetParams()
                    stackLayout.currentIndex = 1
                }
            }

            // 空状态提示（页面 1） —— 当没有选中任何连接时显示
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1a1a2e"
                radius: 8
                border.color: "#252540"
                border.width: 1

                // 提示用户选择或新建连接
                Label {
                    anchors.centerIn: parent
                    text: "选择一个连接或新建连接"
                    font.pixelSize: 14
                    color: "#505068"
                }
            }
        }
    }
}
