// 主内容区域
// 管理应用的四个页面（运行、连接、布局、脚本）的切换
// 负责创建和初始化算法管理器、连接管理器、全局变量管理器和脚本管理器
// 协调布局设置与运行视图之间的通信，以及运行视图与全局脚本编辑器之间的通信

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.connectionManager
import com.lcy.algorithmManager

Item {
    id: root
    // 切换当前显示的页面索引，0:运行, 1:连接, 2:布局, 3:脚本
    function changeIndex(index) {
        contentLayout.currentIndex = index
    }

    // 连接管理器实例，管理 Modbus、串口、相机等通信连接
    ConnectionManager{
        id: connectionManager
    }


    // 算法管理器实例，管理"边缘检测"和"缺陷识别"等算法
    property var algoManager: AlgorithmManager { id: algoManager }
    // 全局变量管理器实例，用于读写全局变量
    property var globalVarMgr: GlobalVariableManager { id: globalVarMgr }
    // 脚本管理器实例，管理每个图像窗口对应的脚本引擎
    // 绑定了算法管理器、连接管理器、全局变量管理器和日志记录器
    property var scriptManager: ScriptManager {
        id: scriptManager
        algorithmManager: algoManager
        connectionMgr: connectionManager
        globalVariableManager: globalVarMgr
        logger: Logger
    }

    // 打开全局变量管理弹窗
    function openGlobalVars() {
        globalVarPopup.open()
    }

    // 组件初始化时创建默认的算法和通信连接
    // 包括：边缘检测和缺陷识别算法、Modbus 连接、串口连接、相机连接
    Component.onCompleted: {
        algoManager.createAlgorithm("边缘检测", "default");
        algoManager.createAlgorithm("缺陷识别", "default");

        connectionManager.createConnection("modbus1", "modbusTcp", {
            ip: "127.0.0.1", port: 502, slaveId: 1
        });
        connectionManager.createConnection("serial1", "serial", {
            port: "COM1", baudRate: 115200, dataBits: 8,
            stopBits: "1", parity: "None"
        });
        connectionManager.createConnection("camera1", "camera", {});

        var cam = connectionManager.connection("camera1");
        if (cam) cam.connect();

        Logger.setStatus("连接管理初始化完成")
    }

    // 页面栈布局，根据 currentIndex 显示不同的子页面
    StackLayout {
        id: contentLayout
        currentIndex: 0
        anchors.fill: parent

        // 运行视图页面（索引 0）
        RunView {
            id: runView
            scriptMgr: scriptManager
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // 连接管理页面（索引 1）
        ConnectionView {
            connMgr: connectionManager
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // 布局设置页面（索引 2）
        LayoutSetting {
            id: layoutSettings
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        // 全局脚本编辑页面（索引 3）
        GlobalScript {
            id: globalScript
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    // 监听布局设置页面的 layoutApplied 信号
    // 将布局参数应用到运行视图
    Connections {
        target: layoutSettings
        function onLayoutApplied(columns, windowCount, rowSpacing, columnSpacing) {
            runView.columns = columns
            runView.windowCount = windowCount
            runView.rowSpacing = rowSpacing
            runView.columnSpacing = columnSpacing
        }
    }

    // 监听运行视图的 modifyScriptMgr 信号
    // 当窗口数量变化时，更新全局脚本编辑器的脚本引擎引用
    Connections {
        target: runView
        function onModifyScriptMgr(count){
          globalScript.scriptEngine = scriptManager.engineAt(count)
        }
    }

    // 全局变量弹窗实例
    GlobalVariable {
        id: globalVarPopup
        globalVarMgr: root.globalVarMgr
    }
}
