// SerialConnection.h
// 串口连接类，继承自 AbstractConnection。
// 用于通过 RS-232/RS-485 串行接口与设备建立连接和通信。
// 提供端口号、波特率、数据位、停止位、校验位等串口参数配置，支持 QML 属性绑定。

#ifndef SERIALCONNECTION_H
#define SERIALCONNECTION_H

#include "AbstractConnection.h"
#include <QtQml/qqmlregistration.h>

class SerialConnection : public AbstractConnection
{
    Q_OBJECT

    // 串口端口名称，如 COM1、/dev/ttyUSB0 等，默认 COM1
    Q_PROPERTY(QString port READ port WRITE setPort NOTIFY portChanged)
    // 波特率（bps），默认 115200
    Q_PROPERTY(int baudRate READ baudRate WRITE setBaudRate NOTIFY baudRateChanged)
    // 数据位（5/6/7/8），默认 8
    Q_PROPERTY(int dataBits READ dataBits WRITE setDataBits NOTIFY dataBitsChanged)
    // 停止位（1/1.5/2），默认 "1"
    Q_PROPERTY(QString stopBits READ stopBits WRITE setStopBits NOTIFY stopBitsChanged)
    // 校验位（None/Even/Odd/Mark/Space），默认 "None"
    Q_PROPERTY(QString parity READ parity WRITE setParity NOTIFY parityChanged)

    QML_ELEMENT

public:
    // 构造函数，初始化默认串口参数
    explicit SerialConnection(QObject *parent = nullptr);

    // 获取串口端口名称
    QString port() const;
    // 设置串口端口名称
    void setPort(const QString &port);
    // 获取波特率
    int baudRate() const;
    // 设置波特率
    void setBaudRate(int rate);
    // 获取数据位
    int dataBits() const;
    // 设置数据位
    void setDataBits(int bits);
    // 获取停止位
    QString stopBits() const;
    // 设置停止位
    void setStopBits(const QString &bits);
    // 获取校验位
    QString parity() const;
    // 设置校验位
    void setParity(const QString &parity);

    // 返回当前串口是否已打开并建立连接
    bool connected() const override;
    // 返回连接状态的文本描述
    QString statusText() const override;
    // 返回连接类型标识字符串
    QString connectionType() const override;
    // 打开串口并建立连接
    void connect() override;
    // 关闭串口并断开连接
    void disconnect() override;

signals:
    // 当串口端口名称改变时发出
    void portChanged();
    // 当波特率改变时发出
    void baudRateChanged();
    // 当数据位改变时发出
    void dataBitsChanged();
    // 当停止位改变时发出
    void stopBitsChanged();
    // 当校验位改变时发出
    void parityChanged();

private:
    // 设置连接状态
    void setConnected(bool c);
    // 设置连接状态文本描述
    void setStatusText(const QString &text);

    // 串口端口名称，默认 "COM1"
    QString m_port{"COM1"};
    // 波特率，默认 115200
    int m_baudRate{115200};
    // 数据位，默认 8
    int m_dataBits{8};
    // 停止位，默认 "1"
    QString m_stopBits{"1"};
    // 校验位，默认 "None"
    QString m_parity{"None"};
    // 当前是否已连接
    bool m_connected{false};
    // 连接状态文本描述，默认 "未连接"
    QString m_statusText{QStringLiteral("未连接")};
};

#endif // SERIALCONNECTION_H
