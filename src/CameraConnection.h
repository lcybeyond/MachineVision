#ifndef CAMERACONNECTION_H
#define CAMERACONNECTION_H

// CameraConnection — 相机连接管理类
// 继承自 AbstractConnection，负责管理相机的连接状态、图像采集和临时文件存储。
// 用于 QML 前端与相机硬件之间的桥接，提供图像路径属性供界面绑定显示。

#include "AbstractConnection.h"
#include <QImage>
#include <QVariant>
#include <QtQml/qqmlregistration.h>

class CameraConnection : public AbstractConnection
{
    Q_OBJECT

    // width: 相机采集图像的宽度（像素），常量属性
    Q_PROPERTY(int width READ width CONSTANT)
    // height: 相机采集图像的高度（像素），常量属性
    Q_PROPERTY(int height READ height CONSTANT)
    // imagePath: 当前采集图像保存的临时文件路径，图像更新时发出通知
    Q_PROPERTY(QString imagePath READ imagePath NOTIFY imagePathChanged)

    QML_ELEMENT

public:
    // 构造函数，初始化相机连接对象，默认状态为未连接
    explicit CameraConnection(QObject *parent = nullptr);

    // 返回相机图像宽度
    int width() const;
    // 返回相机图像高度
    int height() const;
    // 返回当前采集图像的文件路径
    QString imagePath() const;

    // 返回连接状态（已连接/未连接）
    bool connected() const override;
    // 返回当前连接状态的文本描述
    QString statusText() const override;
    // 返回连接类型标识字符串
    QString connectionType() const override;
    // 建立相机连接
    void connect() override;
    // 断开相机连接
    void disconnect() override;

    // 执行一次图像采集，返回包含采集结果的 QVariant
    Q_INVOKABLE QVariant capture();

signals:
    // 当采集图像路径发生变化时发出此信号
    void imagePathChanged();

private:
    // 生成测试图案图像（用于无实际相机时的模拟采集）
    QImage generateTestPattern() const;
    // 将图像保存到临时文件，返回文件路径
    QString saveImageToTempFile(const QImage &img);
    // 设置当前连接状态的文本描述
    void setStatusText(const QString &text);

    int m_width{320};
    int m_height{240};
    bool m_connected{false};
    QString m_statusText{QStringLiteral("未连接")};
    QString m_imagePath;
};

#endif // CAMERACONNECTION_H
