import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import com.lcy.connectionManager
import com.lcy.algorithmManager

Item {
    id: root
    function changeIndex(index) {
        contentLayout.currentIndex = index
    }

    ConnectionManager{
        id: connectionManager
    }


    property var algoManager: AlgorithmManager { id: algoManager }
    property var globalVarMgr: GlobalVariableManager { id: globalVarMgr }
    property var scriptManager: ScriptManager {
        id: scriptManager
        algorithmManager: algoManager
        connectionMgr: connectionManager
        globalVariableManager: globalVarMgr
        logger: Logger
    }

    function openGlobalVars() {
        globalVarPopup.open()
    }

    // ---- 创建算法（与窗口无关） ----
    Component.onCompleted: {
        algoManager.createAlgorithm("边缘检测", "default");
        algoManager.createAlgorithm("缺陷识别", "default");
        Logger.setStatus("连接管理初始化完成")
    }

    StackLayout {
        id: contentLayout
        currentIndex: 0
        anchors.fill: parent

        RunView {
            id: runView
            scriptMgr: scriptManager
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        ConnectionView {
            connMgr: connectionManager
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        LayoutSetting {
            id: layoutSettings
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        GlobalScript {
            id: globalScript
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Connections {
        target: layoutSettings
        function onLayoutApplied(columns, windowCount, rowSpacing, columnSpacing) {
            runView.columns = columns
            runView.windowCount = windowCount
            runView.rowSpacing = rowSpacing
            runView.columnSpacing = columnSpacing
        }
    }

    Connections {
        target: runView
        function onModifyScriptMgr(count){
          globalScript.scriptEngine = scriptManager.engineAt(count)
        }
    }

    GlobalVariable {
        id: globalVarPopup
        globalVarMgr: root.globalVarMgr
    }
}
