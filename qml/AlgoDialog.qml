import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

Popup {
    id: root
    anchors.centerIn: Overlay.overlay
    width: Overlay.overlay.width * 0.6
    height: Overlay.overlay.height * 0.8
    focus: true
    closePolicy: Popup.CloseOnEscape
    modal: true
    padding: 0

    property string algorithmName: "默认算法"

    property string defaultCode: `/**
    * 视觉检测算法
    * 参数:
    *   input  - 输入图像 (cv::Mat)
    *   output - 输出图像 (cv::Mat)
    * 返回: 检测结果
    */
    #include <opencv2/opencv.hpp>
    #include <vector>

    struct DetectResult {
    bool ok;
    std::vector<cv::Rect> regions;
    double confidence;
    };

    DetectResult process(const cv::Mat& input, cv::Mat& output) {
    DetectResult result;
    result.ok = false;

    if (input.empty()) return result;

    cv::Mat gray, blurred, edges;

    // 1. 转灰度图
    cv::cvtColor(input, gray, cv::COLOR_BGR2GRAY);

    // 2. 高斯模糊去噪
    cv::GaussianBlur(gray, blurred, cv::Size(5, 5), 0);

    // 3. Canny 边缘检测
    cv::Canny(blurred, edges, 50, 150);

    // 4. 查找轮廓
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(edges, contours, cv::RETR_EXTERNAL,
    cv::CHAIN_APPROX_SIMPLE);

    // 5. 筛选有效区域
    for (const auto& contour : contours) {
    cv::Rect rect = cv::boundingRect(contour);
    if (rect.area() > 100) {
    result.regions.push_back(rect);
    cv::rectangle(output, rect, cv::Scalar(0, 255, 0), 2);
    }
    }

    result.ok = !result.regions.empty();
    result.confidence = result.ok ? 0.95 : 0.0;
    return result;
    }`

    // ---------- 内容区 ----------
    contentItem: Rectangle {
        color: "#1e1e1e"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ======== 工具栏 ========
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: "#2d2d2d"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 4

                    Item {
                        Layout.fillWidth: true
                    }

                    Button {
                        Layout.fillHeight: true
                        text: "应用"
                        flat: true
                        font.pixelSize: 16
                        Material.foreground: "#4ec9b0"
                        onClicked: root.close()
                    }
                }
            }

            // ======== 代码编辑区 ========
            ScrollView {
                id: scrollView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                contentWidth: editorRow.width
                contentHeight: editorRow.height

                Row {
                    id: editorRow
                    height: codeEdit.contentHeight

                    // -- 行号栏 --
                    Rectangle {
                        id: gutter
                        width: 48
                        height: codeEdit.contentHeight
                        color: "#1e1e1e"

                        Column {
                            anchors.right: parent.right
                            anchors.rightMargin: 8

                            Repeater {
                                model: Math.max(codeEdit.lineCount, 1)

                                Label {
                                    width: 36
                                    height: 20
                                    text: index + 1
                                    color: "#858585"
                                    font.family: "Menlo"
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                    }

                    // -- 分隔线 --
                    Rectangle {
                        width: 1
                        height: codeEdit.contentHeight
                        color: "#3c3c3c"
                    }

                    // -- 代码编辑 --
                    TextEdit {
                        id: codeEdit
                        width: Math.max(scrollView.availableWidth - 49,
                                        contentWidth + 32)
                        height: contentHeight
                        leftPadding: 16
                        color: "#d4d4d4"
                        font.family: "Menlo"
                        font.pixelSize: 13
                        text: root.defaultCode
                        tabStopDistance: 32
                        selectByMouse: true
                        persistentSelection: true
                        wrapMode: TextEdit.NoWrap
                        selectionColor: "#264f78"
                        selectedTextColor: "#ffffff"
                        cursorVisible: true
                        activeFocusOnPress: true
                    }
                }
            }
        }
    }
}
