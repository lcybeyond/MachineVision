import QtQuick
import QtQuick.Controls.Material

Item {
    id: root
    width: 200
    height: 200
    property var windowScriptEngine: null
    property var windowIndex: null
    Item {
        id: item
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.height * 0.75
        clip: true
        Rectangle { anchors.fill: parent; color: "red" }

        // 图片容器：缩放和位移统一管理
        Item {
            id: imgContainer
            width: parent.width
            height: parent.height

            property real scaleVal: 1.0

            transform: Scale {
                id: imgScale
                xScale: imgContainer.scaleVal
                yScale: imgContainer.scaleVal
            }

            Image {
                id: image
                anchors.fill: parent
                source: "qrc:/icons/run.svg"
                fillMode: Image.PreserveAspectFit
            }
        }

        // 鼠标交互层：独立于 imgContainer，避免坐标系冲突
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true

            property real lastX: 0
            property real lastY: 0
            property bool dragging: false

            onPressed: function(mouse) {
                lastX = mouse.x
                lastY = mouse.y
                dragging = true
            }

            onPositionChanged: function(mouse) {
                if (!dragging) return
                // 用增量方式移动，避免与滚轮修改 x/y 冲突
                imgContainer.x += mouse.x - lastX
                imgContainer.y += mouse.y - lastY
                lastX = mouse.x
                lastY = mouse.y
            }

            onReleased: {
                dragging = false
            }

            // 滚轮缩放（以鼠标位置为中心）
            onWheel: function(wheel) {
                wheel.accepted = true

                var oldScale = imgContainer.scaleVal
                var factor = wheel.angleDelta.y > 0 ? 1.1 : 0.9
                var newScale = oldScale * factor
                newScale = Math.max(0.3, Math.min(5.0, newScale))

                if (Math.abs(newScale - oldScale) < 0.001) return

                // 鼠标在 item（父容器）坐标系中的位置
                var mx = wheel.x
                var my = wheel.y

                // 以鼠标位置为中心缩放的公式：
                // 该点在缩放前 = mx - oldX（相对于 imgContainer 原点的偏移）
                // 缩放后保持不动 => newOffset = oldOffset * (newScale / oldScale)
                // => mx - newX = (mx - oldX) * newScale/oldScale
                // => newX = mx - (mx - oldX) * newScale/oldScale
                imgContainer.x = mx - (mx - imgContainer.x) * (newScale / oldScale)
                imgContainer.y = my - (my - imgContainer.y) * (newScale / oldScale)
                imgContainer.scaleVal = newScale
            }

            // 双击复位
            onDoubleClicked: {
                imgContainer.scaleVal = 1.0
                imgContainer.x = 0
                imgContainer.y = 0
            }
        }
    }

    Rectangle {
        width: parent.width
        height: root.height * 0.25
        color: "green"
        anchors.top: item.bottom
    }

    Button {
        width: 50
        height: 50
        anchors.top: root.top
        anchors.right: root.right
        icon.source: "qrc:/icons/configure.svg"
        icon.color: "transparent"
        onClicked: algoDialog.open()
    }

    AlgoDialog{
        id: algoDialog
        scriptEngine: windowScriptEngine
        currentIndex: windowIndex
    }
}
