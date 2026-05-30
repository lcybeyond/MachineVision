import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: root

    property string connectionType: "serial"

    // 串口属性
    property alias portName: portNameField.currentText
    property alias baudRate: baudRateBox.currentValue
    property alias dataBits: dataBitsBox.currentValue
    property alias stopBits: stopBitsBox.currentText
    property alias parity: parityBox.currentText

    // Modbus TCP 属性
    property alias ipAddress: ipField.text
    property alias tcpPort: tcpPortBox.value
    property alias slaveId: slaveIdBox.value

    // 当前连接参数（只读汇总）
    readonly property var connectionParams: connectionType === "serial"
          ? ({"type": "serial","port": portName,"baudRate": baudRate,"dataBits": dataBits,"stopBits": stopBits,"parity": parity})
          : ({"type": "modbusTcp","ip": ipAddress,"port": tcpPort,"slaveId": slaveId})

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        // 连接类型选择
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

        // 串口设置
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

                Label {
                    text: "端口号"
                    Layout.preferredWidth: 80
                    font.pixelSize: 13
                }
                ComboBox {
                    id: portNameField
                    model: ["COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "/dev/ttyUSB0", "/dev/ttyUSB1", "/dev/ttyS0", "/dev/ttyS1"]
                    editable: true
                    Layout.fillWidth: true
                    Layout.preferredWidth: 220
                }

                Label {
                    text: "波特率"
                    font.pixelSize: 13
                }
                ComboBox {
                    id: baudRateBox
                    model: [2400, 4800, 9600, 14400, 19200, 38400, 57600, 115200, 230400, 460800, 921600]
                    currentIndex: 7
                    Layout.fillWidth: true
                }

                Label {
                    text: "数据位"
                    font.pixelSize: 13
                }
                ComboBox {
                    id: dataBitsBox
                    model: [5, 6, 7, 8]
                    currentIndex: 3
                    Layout.fillWidth: true
                }

                Label {
                    text: "停止位"
                    font.pixelSize: 13
                }
                ComboBox {
                    id: stopBitsBox
                    model: ["1", "1.5", "2"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }

                Label {
                    text: "校验位"
                    font.pixelSize: 13
                }
                ComboBox {
                    id: parityBox
                    model: ["None", "Even", "Odd", "Mark", "Space"]
                    currentIndex: 0
                    Layout.fillWidth: true
                }
            }
        }

        // Modbus TCP 设置
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

                Label {
                    text: "IP 地址"
                    Layout.preferredWidth: 80
                    font.pixelSize: 13
                }
                TextField {
                    id: ipField
                    text: "127.0.0.1"
                    placeholderText: "192.168.1.100"
                    validator: RegularExpressionValidator {
                        regularExpression: /^(\d{1,3}\.){0,3}\d{0,3}$/
                    }
                    Layout.fillWidth: true
                }

                Label {
                    text: "端口号"
                    font.pixelSize: 13
                }
                SpinBox {
                    id: tcpPortBox
                    from: 1
                    to: 65535
                    value: 502
                    editable: true
                    Layout.fillWidth: true
                }

                Label {
                    text: "从站 ID"
                    font.pixelSize: 13
                }
                SpinBox {
                    id: slaveIdBox
                    from: 1
                    to: 247
                    value: 1
                    editable: true
                    Layout.fillWidth: true
                }
            }
        }

        // 占位弹簧
        Item {
            Layout.fillHeight: true
        }
    }
}
