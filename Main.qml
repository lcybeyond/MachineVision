import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import com.lcy.algorithmManager

import "./qml"

// 主应用程序窗口 —— MachineVision 视觉检测系统的主入口
// 采用上中下三段式布局：顶部导航栏、中间主内容区、底部状态栏
ApplicationWindow {
    width: 1200
    height: 760
    visible: true
    title: "MachineVision"

    // 全局深色背景色
    color: "#0f0f1a"

    // 主布局容器，使用 ColumnLayout 垂直排列三个区域
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 顶部导航栏组件，提供页面切换和全局变量入口
        TopBar {
            id: topBar
            Layout.fillWidth: true
            Layout.preferredHeight: 52
        }

        // 分隔线 —— 顶部栏与主内容区之间的视觉分隔
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#1e1e32"
        }

        // 主内容区域，使用 StackLayout 切换不同页面（图像显示、检测结果等）
        MainContent {
            id: mainContent
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        // 分隔线 —— 主内容区与底部状态栏之间的视觉分隔
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#1e1e32"
        }

        // 底部状态栏，显示内存使用率、系统状态和版本号
        BottomBar {
            id: bottomBar
            Layout.fillWidth: true
            Layout.preferredHeight: 34
        }
    }

    // 窗口加载完成后的回调，记录初始化状态日志
    Component.onCompleted: Logger.setStatus("主窗口初始化完成")

    // 连接顶部导航栏的信号，实现页面切换和全局变量弹窗的打开
    Connections {
        target: topBar
        // 当用户点击顶部导航标签时触发，切换到对应页面
        function onSwitchPage(index) { mainContent.changeIndex(index) }
        // 当用户点击全局变量按钮时触发，打开全局脚本编辑面板
        function onOpenGlobalVars() { mainContent.openGlobalVars() }
    }
}
