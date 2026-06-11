// ModbusTcpClient.cpp —— Modbus TCP 客户端连接实现
// 提供基于 TCP/IP 的 Modbus 协议通信，支持从站 ID 配置
#include "ModbusTcpClient.h"

ModbusTcpClient::ModbusTcpClient(QObject *parent)
    : AbstractConnection(parent)
{
    // 构造函数：初始化父类 AbstractConnection
}

void ModbusTcpClient::setIpAddress(const QString &ip)
{
    // 设置 Modbus TCP 服务器的 IP 地址，值变化时发出通知
    if (m_ipAddress != ip) {
        m_ipAddress = ip;
        emit ipAddressChanged();
    }
}

void ModbusTcpClient::setPort(int port)
{
    // 设置 Modbus TCP 服务器的端口号，值变化时发出通知
    if (m_port != port) {
        m_port = port;
        emit portChanged();
    }
}

void ModbusTcpClient::setSlaveId(int id)
{
    // 设置 Modbus 从站 ID，值变化时发出通知
    if (m_slaveId != id) {
        m_slaveId = id;
        emit slaveIdChanged();
    }
}

// ---------- 内部 ----------

void ModbusTcpClient::setConnected(bool c)
{
    // 设置连接状态（已连接/未连接），值变化时发出通知
    if (m_connected != c) {
        m_connected = c;
        emit connectedChanged();
    }
}

void ModbusTcpClient::setStatusText(const QString &text)
{
    // 设置状态文本信息，值变化时发出通知
    if (m_statusText != text) {
        m_statusText = text;
        emit statusTextChanged();
    }
}

void ModbusTcpClient::connect()
{
    // 连接到 Modbus TCP 服务器，更新连接状态和状态文本
    if (!m_connected) {
        setConnected(true);
        setStatusText(QStringLiteral("已连接"));
    }
}

void ModbusTcpClient::disconnect()
{
    // 断开与 Modbus TCP 服务器的连接，更新连接状态和状态文本
    if (m_connected) {
        setConnected(false);
        setStatusText(QStringLiteral("未连接"));
    }
}
