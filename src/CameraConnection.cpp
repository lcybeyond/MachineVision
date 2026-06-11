// CameraConnection.cpp - 相机连接实现
// 提供模拟相机功能，包括连接管理、图像采集和测试图案生成。
// 用于在没有实际硬件的情况下进行算法测试和界面调试。

#include "CameraConnection.h"
#include <QPainter>
#include <QDir>
#include <QDateTime>
#include <QFont>

CameraConnection::CameraConnection(QObject *parent)
    : AbstractConnection(parent)
{
}

// 获取图像宽度
int CameraConnection::width() const { return m_width; }
// 获取图像高度
int CameraConnection::height() const { return m_height; }
// 获取当前图像文件的路径
QString CameraConnection::imagePath() const { return m_imagePath; }

// 获取连接状态
bool CameraConnection::connected() const { return m_connected; }
// 获取状态文本描述
QString CameraConnection::statusText() const { return m_statusText; }
// 返回连接类型标识
QString CameraConnection::connectionType() const { return QStringLiteral("camera"); }

// 建立相机连接
// 生成测试图案并保存到临时文件，设置连接状态为已连接
void CameraConnection::connect()
{
    if (!m_connected) {
        QImage img = generateTestPattern();
        m_imagePath = saveImageToTempFile(img);
        emit imagePathChanged();
        m_connected = true;
        setStatusText(QStringLiteral("已连接 - 模拟相机"));
        emit connectedChanged();
    }
}

// 断开相机连接
// 将连接状态设置为未连接
void CameraConnection::disconnect()
{
    if (m_connected) {
        m_connected = false;
        setStatusText(QStringLiteral("未连接"));
        emit connectedChanged();
    }
}

// 采集一帧图像
// 生成新的测试图案并保存到临时文件，返回 QImage 对象
QVariant CameraConnection::capture()
{
    QImage img = generateTestPattern();
    m_imagePath = saveImageToTempFile(img);
    emit imagePathChanged();
    return QVariant::fromValue(img);
}

// 生成模拟测试图案
// 绘制包含渐变背景、十字准线、同心圆标定靶、矩形 ROI、
// 文字标签和随机散点的合成图像，用于模拟工业相机视野
QImage CameraConnection::generateTestPattern() const
{
    QImage img(m_width, m_height, QImage::Format_ARGB32);
    img.fill(Qt::black);

    QPainter p(&img);
    p.setRenderHint(QPainter::Antialiasing);

    // Gradient background
    QLinearGradient grad(0, 0, m_width, m_height);
    grad.setColorAt(0.0, QColor(30, 30, 60));
    grad.setColorAt(0.5, QColor(50, 50, 80));
    grad.setColorAt(1.0, QColor(20, 40, 50));
    p.fillRect(0, 0, m_width, m_height, grad);

    // Crosshairs
    p.setPen(QPen(QColor(0, 255, 0, 120), 1));
    p.drawLine(m_width / 2, 0, m_width / 2, m_height);
    p.drawLine(0, m_height / 2, m_width, m_height / 2);

    // Concentric circles (simulated calibration target)
    QPoint center(m_width / 2 + 15, m_height / 2 - 10);
    p.setPen(QPen(QColor(255, 80, 80, 180), 2));
    p.drawEllipse(center, 70, 70);
    p.drawEllipse(center, 50, 50);
    p.drawEllipse(center, 30, 30);
    p.drawEllipse(center, 10, 10);

    // Blue target circle
    QPoint center2(m_width / 2 - 30, m_height / 2 + 25);
    p.setPen(QPen(QColor(80, 80, 255, 180), 2));
    p.drawEllipse(center2, 40, 40);
    p.drawEllipse(center2, 20, 20);

    // Rectangle region of interest
    p.setPen(QPen(QColor(255, 255, 0, 100), 1.5, Qt::DashLine));
    p.drawRect(QRect(40, 40, 100, 80));

    // Label rectangle
    p.fillRect(QRect(m_width / 2 - 60, 8, 120, 22), QColor(0, 0, 0, 140));

    // Text
    QFont font("Arial", 11, QFont::Bold);
    p.setFont(font);
    p.setPen(QColor(255, 255, 255));
    p.drawText(QRect(0, 8, m_width, 22), Qt::AlignHCenter, "TEST TARGET");

    // Scale info
    QFont smallFont("Arial", 8);
    p.setFont(smallFont);
    p.setPen(QColor(180, 180, 180));
    p.drawText(QRect(4, m_height - 16, 100, 14), Qt::AlignLeft,
               QString("320x240 #%1").arg(m_name));

    // Some random dots (simulated particles/defects)
    p.setPen(Qt::NoPen);
    int seed = 42;
    for (int i = 0; i < 15; ++i) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        int x = 30 + (seed % (m_width - 60));
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        int y = 30 + (seed % (m_height - 60));
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        int r = 2 + (seed % 4);
        p.setBrush(QColor(255, 255, 200, 180));
        p.drawEllipse(QPoint(x, y), r, r);
    }

    p.end();
    return img;
}

// 将图像保存到系统临时目录
// 文件名基于相机名称生成，格式为 PNG
QString CameraConnection::saveImageToTempFile(const QImage &img)
{
    QString path = QDir::tempPath() + "/camera_" + m_name + ".png";
    img.save(path, "PNG");
    return path;
}

// 设置状态文本
// 仅在文本发生变化时更新并发射信号，避免不必要的 UI 刷新
void CameraConnection::setStatusText(const QString &text)
{
    if (m_statusText != text) {
        m_statusText = text;
        emit statusTextChanged();
    }
}
