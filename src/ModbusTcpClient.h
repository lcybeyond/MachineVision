// ModbusTcpClient.h
// Modbus TCP 客户端连接类，继承自 AbstractConnection。
// 用于通过 Modbus TCP 协议与工业设备（PLC、传感器等）建立网络连接和通信。
// 提供 IP 地址、端口号、从站 ID 等连接参数配置，支持 QML 属性绑定。

#ifndef MODBUSTCPCLIENT_H
#define MODBUSTCPCLIENT_H

#include <QObject>
#include <QModbusClient>
#include <QModbusDataUnit>
#include <QModbusReply>
#include <QtQml/qqmlregistration.h>
#include "AbstractConnection.h"


class ModbusTcpClient : public AbstractConnection
{
    Q_OBJECT

    // 连接参数（QML → C++）
    // 目标设备的 IP 地址，默认 127.0.0.1
    Q_PROPERTY(QString ipAddress READ ipAddress WRITE setIpAddress NOTIFY ipAddressChanged)
    // 目标设备的 TCP 端口号，默认 502（Modbus 标准端口）
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    // Modbus 从站 ID，默认 1
    Q_PROPERTY(int slaveId READ slaveId WRITE setSlaveId NOTIFY slaveIdChanged)

    // 连接状态（C++ → QML）
    // 当前是否已连接到设备
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    // 连接状态的文本描述，如"已连接"或错误信息
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)

    QML_ELEMENT

public:
    // 构造函数，初始化默认连接参数
    explicit ModbusTcpClient(QObject *parent = nullptr);
    // 析构函数，使用默认实现
    ~ModbusTcpClient() override = default;

    // 获取目标设备的 IP 地址
    QString ipAddress() const { return m_ipAddress; }
    // 设置目标设备的 IP 地址
    void setIpAddress(const QString &ip);

    // 获取目标设备的 TCP 端口号
    int port() const { return m_port; }
    // 设置目标设备的 TCP 端口号
    void setPort(int port);

    // 获取 Modbus 从站 ID
    int slaveId() const { return m_slaveId; }
    // 设置 Modbus 从站 ID
    void setSlaveId(int id);

    // 返回当前是否已连接
    bool connected() const override { return m_connected; }
    // 返回连接状态的文本描述
    QString statusText() const override { return m_statusText; }
    // 返回连接类型标识字符串
    QString connectionType() const override { return QStringLiteral("modbusTcp"); }
    // 发起与目标设备的 TCP 连接
    void connect() override;
    // 断开与目标设备的连接
    void disconnect() override;

signals:
    // 当 IP 地址属性值改变时发出
    void ipAddressChanged();
    // 当端口号属性值改变时发出
    void portChanged();
    // 当从站 ID 属性值改变时发出
    void slaveIdChanged();


private:
    // 设置连接状态，同时更新 statusText
    void setConnected(bool c);
    // 设置连接状态文本描述
    void setStatusText(const QString &text);


    // 目标设备 IP 地址，默认 127.0.0.1
    QString m_ipAddress{"127.0.0.1"};
    // 目标设备 TCP 端口号，默认 502
    int m_port{502};
    // Modbus 从站 ID，默认 1
    int m_slaveId{1};
    // 当前连接状态
    bool m_connected{false};
    // 连接状态的文本描述，默认"未连接"
    QString m_statusText{"未连接"};
};

#endif // MODBUSTCPCLIENT_H
