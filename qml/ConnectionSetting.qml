import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

Item {
    id: root

    property var connMgr: null
    property int connectionIndex: 0
    property string fileName: ""

    property string connectionType: "serial"
    property bool autoConnect: false

    signal saved(int index, string fileName, string paramsJson)
    signal deleted(int index)

    function loadParams(params) {
        if (!params || !params.type) return
        autoConnect = params.autoConnect === true
        if (params.type === "serial") {
            connectionType = "serial"
            tabBar.currentIndex = 0
            portNameField.currentIndex = portNameField.find(params.port)
            baudRateBox.currentIndex = baudRateBox.find(params.baudRate)
            dataBitsBox.currentIndex = dataBitsBox.find(params.dataBits)
            stopBitsBox.currentIndex = stopBitsBox.find(params.stopBits)
            parityBox.currentIndex = parityBox.find(params.parity)
        } else if (params.type === "modbusTcp") {
            connectionType = "modbusTcp"
            tabBar.currentIndex = 1
            ipField.text = params.ip || "127.0.0.1"
            tcpPortBox.value = params.port || 502
            slaveIdBox.value = params.slaveId || 1
        }
    }

    function resetParams() {
        connectionType = "serial"
        tabBar.currentIndex = 0
        portNameField.currentIndex = 0
        baudRateBox.currentIndex = 7
        dataBitsBox.currentIndex = 3
        stopBitsBox.currentIndex = 0
        parityBox.currentIndex = 0
        ipField.text = "127.0.0.1"
        tcpPortBox.value = 502
        slaveIdBox.value = 1
        autoConnect = false
    }

    property alias portName: portNameField.currentText
    property alias baudRate: baudRateBox.currentValue
    property alias dataBits: dataBitsBox.currentValue
    property alias stopBits: stopBitsBox.currentText
    property alias parity: parityBox.currentText

    property alias ipAddress: ipField.text
    property alias tcpPort: tcpPortBox.value
    property alias slaveId: slaveIdBox.value

    readonly property var connectionParams: connectionType === "serial"
          ? ({"type": "serial","port": portName,"baudRate": baudRate,"dataBits": dataBits,"stopBits": stopBits,"parity": parity})
          : ({"type": "modbusTcp","ip": ipAddress,"port": tcpPort,"slaveId": slaveId})

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        RowLayout {
            Layout.preferredHeight: 44
            spacing: 12

            Label {
                text: "连接类型"
                Layout.preferredWidth: 72
                font.pixelSize: 14
                color: Material.primaryTextColor
            }

            TabBar {
                id: tabBar
                Layout.preferredWidth: 260

                TabButton {
                    text: "串口"
                    width: 130
                    font.pixelSize: 13
                }
                TabButton {
                    text: "Modbus TCP"
                    width: 130
                    font.pixelSize: 13
                }

                onCurrentIndexChanged: {
                    root.connectionType = currentIndex === 0 ? "serial" : "modbusTcp"
                }
            }
        }

        GroupBox {
            title: "串口参数"
            visible: connectionType === "serial"
            Layout.fillWidth: true

            background: Rectangle {
                y: parent.topPadding - parent.bottomPadding
                width: parent.width
                height: parent.height - parent.topPadding + parent.bottomPadding
                color: "transparent"
                border.color: "#e0e0e0"
                radius: 6
            }

            GridLayout {
                anchors.fill: parent
                columns: 2
                rowSpacing: 14
                columnSpacing: 16

                Label { text: "端口号"; Layout.preferredWidth: 80; font.pixelSize: 13 }
                ComboBox {
                    id: portNameField
                    model: ["COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "/dev/ttyUSB0", "/dev/ttyUSB1", "/dev/ttyS0", "/dev/ttyS1"]
                    editable: true
                    Layout.fillWidth: true
                }

                Label { text: "波特率"; font.pixelSize: 13 }
                ComboBox {
                    id: baudRateBox
                    model: [2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 230400, 460800, 921600]
                    currentIndex: 7
                    Layout.fillWidth: true
                }

                Label { text: "数据位"; font.pixelSize: 13 }
                ComboBox {
                    id: dataBitsBox
                    model: [5, 6, 7, 8]
                    currentIndex: 3
                    Layout.fillWidth: true
                }

                Label { text: "停止位"; font.pixelSize: 13 }
                ComboBox {
                    id: stopBitsBox
                    model: ["1", "1.5", "2"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }

                Label { text: "校验位"; font.pixelSize: 13 }
                ComboBox {
                    id: parityBox
                    model: ["None", "Even", "Odd", "Mark", "Space"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }
            }
        }

        GroupBox {
            title: "Modbus TCP 参数"
            visible: connectionType === "modbusTcp"
            Layout.fillWidth: true

            background: Rectangle {
                y: parent.topPadding - parent.bottomPadding
                width: parent.width
                height: parent.height - parent.topPadding + parent.bottomPadding
                color: "transparent"
                border.color: "#e0e0e0"
                radius: 6
            }

            GridLayout {
                anchors.fill: parent
                columns: 2
                rowSpacing: 14
                columnSpacing: 16

                Label { text: "IP 地址"; Layout.preferredWidth: 80; font.pixelSize: 13 }
                TextField {
                    id: ipField
                    text: "127.0.0.1"
                    placeholderText: "192.168.1.100"
                    validator: RegularExpressionValidator {
                        regularExpression: /^(\d{1,3}\.){0,3}\d{0,3}$/
                    }
                    Layout.fillWidth: true
                }

                Label { text: "端口号"; font.pixelSize: 13 }
                SpinBox {
                    id: tcpPortBox
                    from: 1; to: 65535; value: 502
                    editable: true
                    Layout.fillWidth: true
                }

                Label { text: "从站 ID"; font.pixelSize: 13 }
                SpinBox {
                    id: slaveIdBox
                    from: 1; to: 247; value: 1
                    editable: true
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            CheckBox {
                id: autoConnectBox
                checked: root.autoConnect
                onCheckedChanged: root.autoConnect = checked
            }
            Label {
                text: "自动连接"
                font.pixelSize: 13
                color: Material.primaryTextColor
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TextField {
                id: fileNameField
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                text: root.fileName
                placeholderText: "连接配置文件名"
                placeholderTextColor: "#999999"
            }

            Button {
                Layout.preferredHeight: 32
                text: "保存配置"
                font.pixelSize: 12
                Material.background: "#0e639c"
                Material.foreground: "#ffffff"
                onClicked: {
                    root.fileName = fileNameField.text
                    var fileParams = JSON.parse(JSON.stringify(root.connectionParams))
                    fileParams.autoConnect = root.autoConnect
                    if (!fileParams.createdAt) {
                        fileParams.createdAt = Date.now()
                    }
                    var path = FileConfig.connDir() + "/" + root.fileName
                    FileConfig.writeFile(path, JSON.stringify(fileParams, null, 2))
                    var connName = root.fileName.replace(/\.json$/, "")
                    connMgr.removeConnection(connName)
                    connMgr.createConnection(connName, root.connectionType, root.connectionParams)
                    root.saved(root.connectionIndex, root.fileName, JSON.stringify(fileParams))

                }
            }

            Button {
                Layout.preferredHeight: 32
                text: "删除"
                font.pixelSize: 12
                Material.background: "#c0392b"
                Material.foreground: "#ffffff"
                onClicked: {
                    var path = FileConfig.connDir() + "/" + root.fileName
                    FileConfig.deleteFile(path)
                    var connName = root.fileName.replace(/\.json$/, "")
                    connMgr.removeConnection(connName)
                    root.deleted(root.connectionIndex)
                }
            }
        }

        Button {
            Layout.preferredHeight: 48
            Layout.fillWidth: true
            text: {
                var connName = root.fileName.replace(/\.json$/, "")
                var conn = connMgr ? connMgr.connection(connName) : null
                return (conn && conn.connected) ? "断开" : "连接"
            }
            Material.background: {
                var connName = root.fileName.replace(/\.json$/, "")
                var conn = connMgr ? connMgr.connection(connName) : null
                return (conn && conn.connected) ? "#c0392b" : "#27ae60"
            }
            Material.foreground: "#ffffff"
            onClicked: {
                var connName = root.fileName.replace(/\.json$/, "")
                var conn = connMgr ? connMgr.connection(connName) : null
                if (!conn) {
                    conn = connMgr.createConnection(connName, root.connectionType, root.connectionParams)
                }
                if (conn) {
                    if (conn.connected) conn.disconnect()
                    else conn.connect()
                }
            }
        }
    }
}
