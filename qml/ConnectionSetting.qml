import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.algorithmManager

// 连接配置面板 —— 用于配置单个连接的参数
// 支持三种连接类型：串口通信、Modbus TCP 和相机
// 提供参数表单、配置文件保存/删除、连接/断开操作
Rectangle {
    id: root
    color: "#1a1a2e"
    radius: 8
    border.color: "#252540"
    border.width: 1

    // 连接管理器对象，负责创建、管理和销毁连接实例
    property var connMgr: null
    // 当前连接在列表中的索引
    property int connectionIndex: 0
    // 配置文件名称（含 .json 扩展名）
    property string fileName: ""
    // 当前选中的连接类型："serial"、"modbusTcp" 或 "camera"
    property string connectionType: "serial"
    // 是否启用自动连接（应用启动时自动建立连接）
    property bool autoConnect: false

    // 保存成功信号 —— 连接配置保存到文件后发射
    // 参数：index 连接索引, fileName 文件名, paramsJson 参数 JSON 字符串
    signal saved(int index, string fileName, string paramsJson)
    // 删除成功信号 —— 连接配置文件被删除后发射
    // 参数：index 被删除的连接索引
    signal deleted(int index)

    // 组件初始化完成，记录日志
    Component.onCompleted: Logger.setStatus("连接设置初始化完成")

    // 从参数对象加载配置到 UI 表单，支持串口、Modbus TCP 和相机三种类型
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
        } else if (params.type === "camera") {
            connectionType = "camera"
            tabBar.currentIndex = 2
        }
    }

    // 重置所有参数到默认值（串口 115200-8-N-1，TCP 127.0.0.1:502，关闭自动连接）
    function resetParams() {
        connectionType = "serial"; tabBar.currentIndex = 0
        portNameField.currentIndex = 0; baudRateBox.currentIndex = 7
        dataBitsBox.currentIndex = 3; stopBitsBox.currentIndex = 0
        parityBox.currentIndex = 0
        ipField.text = "127.0.0.1"; tcpPortBox.value = 502; slaveIdBox.value = 1
        autoConnect = false
    }

    // 以下属性别名暴露给外部，方便直接读取当前表单值
    property alias portName: portNameField.currentText
    property alias baudRate: baudRateBox.currentValue
    property alias dataBits: dataBitsBox.currentValue
    property alias stopBits: stopBitsBox.currentText
    property alias parity: parityBox.currentText
    property alias ipAddress: ipField.text
    property alias tcpPort: tcpPortBox.value
    property alias slaveId: slaveIdBox.value

    // 只读属性：根据当前连接类型，将表单参数组装为 JSON 对象
    readonly property var connectionParams: {
        if (connectionType === "serial")
            return {"type": "serial", "port": portName, "baudRate": baudRate,
                    "dataBits": dataBits, "stopBits": stopBits, "parity": parity}
        if (connectionType === "modbusTcp")
            return {"type": "modbusTcp", "ip": ipAddress, "port": tcpPort, "slaveId": slaveId}
        return {"type": "camera"}
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // 标题
        Label {
            text: "连接配置"
            font.pixelSize: 16
            font.weight: Font.DemiBold
            color: "#e8e8f0"
        }

        // 连接类型选择器 —— 通过三个标签按钮切换串口/Modbus TCP/相机
        RowLayout {
            spacing: 10

            Label {
                text: "类型"
                font.pixelSize: 12
                color: "#9090a0"
                Layout.preferredWidth: 60
            }

            // 使用 Repeater 创建三个类型选择选项卡
            Repeater {
                model: ["串口", "Modbus TCP", "相机"]
                // 类型选项卡 —— 选中时高亮为青色
                Rectangle {
                    Layout.preferredWidth: typeText.implicitWidth + 24
                    Layout.preferredHeight: 30
                    radius: 6
                    // 选中时青色背景，未选中时深色背景
                    color: tabBar.currentIndex === index ? "#0fabbc" : "#1e1e32"
                    border.color: tabBar.currentIndex === index ? "#0fabbc" : "#2d2d45"
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Label {
                        id: typeText
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 12
                        // 选中时深色文字，未选中时灰色文字
                        color: tabBar.currentIndex === index ? "#12121f" : "#9090a0"
                        font.weight: tabBar.currentIndex === index ? Font.DemiBold : Font.Normal
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        // 点击切换连接类型
                        onClicked: {
                            tabBar.currentIndex = index
                            if (index === 0) root.connectionType = "serial"
                            else if (index === 1) root.connectionType = "modbusTcp"
                            else root.connectionType = "camera"
                        }
                    }
                }
            }
        }

        // 隐藏的 TabBar，仅用于维护 currentIndex 状态供类型选择器使用
        TabBar { id: tabBar; visible: false }

        // 串口参数配置面板 —— 仅在连接类型为 serial 时可见
        Rectangle {
            Layout.fillWidth: true
            visible: connectionType === "serial"
            color: "#0f0f1a"
            radius: 6
            border.color: "#1e1e32"
            border.width: 1
            height: serialGrid.implicitHeight + 32

            GridLayout {
                id: serialGrid
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                columns: 2
                rowSpacing: 10
                columnSpacing: 12

                // 端口号选择
                Label { text: "端口号"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                ComboBox {
                    id: portNameField
                    model: ["COM1","COM2","COM3","COM4","COM5","COM6","/dev/ttyUSB0","/dev/ttyUSB1","/dev/ttyS0","/dev/ttyS1"]
                    currentIndex: 0; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: Label { text: portNameField.currentText; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                }

                // 波特率选择（默认 115200，索引 7）
                Label { text: "波特率"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                ComboBox {
                    id: baudRateBox
                    model: [2400,4800,9600,14400,19200,38400,57600,115200,230400,460800,921600]
                    currentIndex: 7; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: Label { text: baudRateBox.currentText; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                }

                // 数据位选择（默认 8 位，索引 3）
                Label { text: "数据位"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                ComboBox {
                    id: dataBitsBox
                    model: [5,6,7,8]
                    currentIndex: 3; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: Label { text: dataBitsBox.currentText; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                }

                // 停止位选择（默认 1 位）
                Label { text: "停止位"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                ComboBox {
                    id: stopBitsBox
                    model: ["1","1.5","2"]
                    currentIndex: 0; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: Label { text: stopBitsBox.currentText; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                }

                // 校验位选择（默认 None）
                Label { text: "校验位"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                ComboBox {
                    id: parityBox
                    model: ["None","Even","Odd","Mark","Space"]
                    currentIndex: 0; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: Label { text: parityBox.currentText; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
                }
            }
        }

        // Modbus TCP 参数配置面板 —— 仅在连接类型为 modbusTcp 时可见
        Rectangle {
            Layout.fillWidth: true
            visible: connectionType === "modbusTcp"
            color: "#0f0f1a"
            radius: 6
            border.color: "#1e1e32"
            border.width: 1
            height: tcpGrid.implicitHeight + 32

            GridLayout {
                id: tcpGrid
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 16
                columns: 2
                rowSpacing: 10
                columnSpacing: 12

                // IP 地址输入框（默认 127.0.0.1）
                Label { text: "IP 地址"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                TextField {
                    id: ipField; text: "127.0.0.1"; Layout.fillWidth: true
                    color: "#e0e0f0"; font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                }

                // TCP 端口号选择（默认 502，范围 1-65535）
                Label { text: "端口号"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                SpinBox {
                    id: tcpPortBox; from: 1; to: 65535; value: 502; editable: true; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: TextInput { text: parent.value; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: TextInput.AlignVCenter }
                }

                // Modbus 从站 ID 选择（默认 1，范围 1-247）
                Label { text: "从站 ID"; font.pixelSize: 12; color: "#9090a0"; Layout.preferredWidth: 70 }
                SpinBox {
                    id: slaveIdBox; from: 1; to: 247; value: 1; editable: true; Layout.fillWidth: true
                    font.pixelSize: 12
                    background: Rectangle { color: "#1a1a2e"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
                    contentItem: TextInput { text: parent.value; font.pixelSize: 12; color: "#e0e0f0"; verticalAlignment: TextInput.AlignVCenter }
                }
            }
        }

        // 相机参数面板 —— 仅在连接类型为 camera 时可见
        // 当前为模拟相机，无需额外配置参数
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            visible: connectionType === "camera"
            color: "#0f0f1a"
            radius: 6
            border.color: "#1e1e32"
            border.width: 1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                // 相机类型说明
                Label { text: "模拟相机"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#e8e8f0"; Layout.alignment: Qt.AlignHCenter }
                // 模拟相机参数说明
                Label { text: "320×240 测试图案 — 无需配置参数"; font.pixelSize: 11; color: "#606078"; Layout.alignment: Qt.AlignHCenter }
            }
        }

        // 自动连接开关 —— 勾选后应用启动时自动建立此连接
        RowLayout {
            spacing: 8
            // 自定义复选框 —— 选中时显示青色背景和勾号
            Rectangle {
                width: 16; height: 16; radius: 3
                color: root.autoConnect ? "#0fabbc" : "#1e1e32"
                border.color: root.autoConnect ? "#0fabbc" : "#2d2d45"; border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                // 勾号标记
                Label {
                    anchors.centerIn: parent
                    text: root.autoConnect ? "✓" : ""
                    font.pixelSize: 10; color: "#12121f"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.autoConnect = !root.autoConnect
                }
            }
            Label { text: "自动连接"; font.pixelSize: 12; color: "#9090a0" }
        }

        // 文件名输入框 + 保存/删除按钮
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // 配置文件名输入框
            TextField {
                id: fileNameField; text: root.fileName; Layout.fillWidth: true
                color: "#e0e0f0"; font.pixelSize: 12
                placeholderText: "配置文件名"; placeholderTextColor: "#505068"
                background: Rectangle { color: "#0f0f1a"; radius: 4; border.color: "#2d2d45"; border.width: 1 }
            }

            // 保存按钮 —— 将当前参数序列化并写入 JSON 配置文件，同时创建/更新连接
            Rectangle {
                Layout.preferredHeight: 32; Layout.preferredWidth: 56; radius: 4
                color: saveBtnHover.hovered ? Qt.lighter("#0fabbc", 1.2) : "#0fabbc"
                Behavior on color { ColorAnimation { duration: 150 } }

                Label {
                    anchors.centerIn: parent; text: "保存"; font.pixelSize: 11
                    font.weight: Font.DemiBold; color: "#ffffff"
                }
                MouseArea {
                    id: saveBtnHover; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.fileName = fileNameField.text
                        var fileParams = JSON.parse(JSON.stringify(root.connectionParams))
                        fileParams.autoConnect = root.autoConnect
                        if (!fileParams.createdAt) fileParams.createdAt = Date.now()
                        var path = FileConfig.connDir() + "/" + root.fileName
                        FileConfig.writeFile(path, JSON.stringify(fileParams, null, 2))
                        var connName = root.fileName.replace(/\.json$/, "")
                        connMgr.removeConnection(connName)
                        connMgr.createConnection(connName, root.connectionType, root.connectionParams)
                        root.saved(root.connectionIndex, root.fileName, JSON.stringify(fileParams))
                    }
                }
            }

            // 删除按钮 —— 删除配置文件并从连接管理器中移除连接
            Rectangle {
                Layout.preferredHeight: 32; Layout.preferredWidth: 56; radius: 4
                color: delBtnHover.hovered ? Qt.lighter("#e74c3c", 1.2) : "#e74c3c"
                Behavior on color { ColorAnimation { duration: 150 } }

                Label {
                    anchors.centerIn: parent; text: "删除"; font.pixelSize: 11
                    font.weight: Font.DemiBold; color: "#ffffff"
                }
                MouseArea {
                    id: delBtnHover; anchors.fill: parent; hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var path = FileConfig.connDir() + "/" + root.fileName
                        FileConfig.deleteFile(path)
                        var connName = root.fileName.replace(/\.json$/, "")
                        connMgr.removeConnection(connName)
                        root.deleted(root.connectionIndex)
                    }
                }
            }
        }

        // 连接/断开按钮 —— 根据当前连接状态显示不同文字和颜色
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 6
            // 动态获取当前连接对象
            property var conn: {
                var cn = root.fileName.replace(/\.json$/, "")
                return connMgr ? connMgr.connection(cn) : null
            }
            // 是否已连接状态，影响按钮颜色和文字
            property bool isConn: conn && conn.connected
            // 已连接时红色背景，未连接时绿色背景
            color: isConn ? "#2a1a1a" : "#1a3a2a"
            border.color: isConn ? "#e74c3c" : "#27ae60"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 200 } }

            // 按钮文字根据连接状态动态切换
            Label {
                anchors.centerIn: parent
                text: parent.isConn ? "断开连接" : "建立连接"
                font.pixelSize: 14; font.weight: Font.DemiBold
                color: parent.isConn ? "#e74c3c" : "#27ae60"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                // 点击时根据当前状态执行连接或断开操作
                onClicked: {
                    var cn = root.fileName.replace(/\.json$/, "")
                    var c = connMgr ? connMgr.connection(cn) : null
                    if (!c) c = connMgr.createConnection(cn, root.connectionType, root.connectionParams)
                    if (c) {
                        if (c.connected) c.disconnect()
                        else c.connect()
                    }
                }
            }
        }

        // 弹性占位，将上方内容推到顶部
        Item { Layout.fillHeight: true }
    }
}
