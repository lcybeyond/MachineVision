#include "ModbusTcpClient.h"

ModbusTcpClient::ModbusTcpClient(QObject *parent)
    : AbstractConnection(parent)
{

}

void ModbusTcpClient::setIpAddress(const QString &ip)
{
    if (m_ipAddress != ip) {
        m_ipAddress = ip;
        emit ipAddressChanged();
    }
}

void ModbusTcpClient::setPort(int port)
{
    if (m_port != port) {
        m_port = port;
        emit portChanged();
    }
}

void ModbusTcpClient::setSlaveId(int id)
{
    if (m_slaveId != id) {
        m_slaveId = id;
        emit slaveIdChanged();
    }
}

// ---------- 内部 ----------

void ModbusTcpClient::setConnected(bool c)
{
    if (m_connected != c) {
        m_connected = c;
        emit connectedChanged();
    }
}

void ModbusTcpClient::setStatusText(const QString &text)
{
    if (m_statusText != text) {
        m_statusText = text;
        emit statusTextChanged();
    }
}
