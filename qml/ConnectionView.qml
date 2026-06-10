import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Item {
    id: root

    property var connMgr: null

    property int selectedIndex: -1

    ListModel {
        id: connListModel
    }

    function loadAllConnections() {
        connListModel.clear()

        var dirPath = FileConfig.connDir()
        var files = FileConfig.listFiles(dirPath)
        if (!files || files.length === 0) return

        var entries = []
        for (var i = 0; i < files.length; i++) {
            if (!/\.json$/i.test(files[i])) continue

            var path = dirPath + "/" + files[i]
            var jsonStr = FileConfig.readFile(path)
            if (jsonStr === "") continue

            var params = {}
            try { params = JSON.parse(jsonStr) } catch (e) { continue }
            if (!params || Array.isArray(params) || !params.type) {
                console.warn("ConnectionView: skipping", files[i], "- not a valid connection object")
                continue
            }

            entries.push({
                fileName: files[i],
                displayName: files[i].replace(/\.json$/i, ""),
                paramsJson: jsonStr,
                params: params,
                createdAt: params.createdAt || 0
            })
        }

        entries.sort(function(a, b) { return a.createdAt - b.createdAt })

        for (var j = 0; j < entries.length; j++) {
            var e = entries[j]
            connListModel.append({
                fileName: e.fileName,
                displayName: e.displayName,
                paramsJson: e.paramsJson
            })

            if (connMgr) {
                connMgr.createConnection(e.displayName, e.params.type, e.params)
                if (e.params.autoConnect === true) {
                    var conn = connMgr.connection(e.displayName)
                    if (conn) conn.connect()
                }
            }
        }
    }

    function selectConnection(index) {
        selectedIndex = index
        var item = connListModel.get(index)
        connectionSettings.connectionIndex = index
        connectionSettings.fileName = item.fileName
        connectionSettings.loadParams(JSON.parse(item.paramsJson))
        stackLayout.currentIndex = 0
    }

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

    Component.onCompleted: loadAllConnections()

    RowLayout {
        id: rowLayout
        anchors.margins: 10
        anchors.fill: parent

        ColumnLayout {
            id: columnLayout
            Layout.preferredWidth: parent.width * 0.2
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop

            Repeater {
                model: connListModel
                Button {
                    Layout.fillWidth: true
                    text: model.displayName
                    highlighted: root.selectedIndex === index
                    onClicked: root.selectConnection(index)
                }
            }

            Button {
                Layout.fillWidth: true
                text: "+ 新建连接"
                icon.source: "qrc:/icons/add.svg"
                icon.color: "transparent"
                onClicked: root.addNewConnection()
            }
        }

        StackLayout {
            id: stackLayout
            Layout.preferredWidth: parent.width * 0.8
            Layout.fillHeight: true
            currentIndex: 1

            ConnectionSetting {
                id: connectionSettings
                connMgr: root.connMgr
                Layout.fillWidth: true
                Layout.fillHeight: true

                onSaved: (index, fileName, paramsJson) => {
                    if (index >= 0 && index < connListModel.count) {
                        connListModel.setProperty(index, "fileName", fileName)
                        connListModel.setProperty(index, "displayName", fileName.replace(/\.json$/i, ""))
                        connListModel.setProperty(index, "paramsJson", paramsJson)
                    }
                    root.selectedIndex = index
                }

                onDeleted: (index) => {
                    if (index >= 0 && index < connListModel.count) {
                        connListModel.remove(index)
                    }
                    root.selectedIndex = -1
                    connectionSettings.resetParams()
                    stackLayout.currentIndex = 1
                }
            }
        }
    }
}
