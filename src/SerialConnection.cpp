// SerialConnection.cpp —— 串口连接实现
// 提供串口通信参数配置（端口号、波特率、数据位、停止位、校验位）及连接/断开管理
#include "SerialConnection.h"

SerialConnection::SerialConnection(QObject *parent)
    : AbstractConnection(parent)
{
    // 构造函数：初始化父类 AbstractConnection
}

QString SerialConnection::port() const { return m_port; }
void SerialConnection::setPort(const QString &port)
{
    // 设置串口端口号（如 COM1、/dev/ttyUSB0），值变化时发出通知
    if (m_port != port) {
        m_port = port;
        emit portChanged();
    }
}

int SerialConnection::baudRate() const { return m_baudRate; }
void SerialConnection::setBaudRate(int rate)
{
    // 设置串口波特率（如 9600、115200），值变化时发出通知
    if (m_baudRate != rate) {
        m_baudRate = rate;
        emit baudRateChanged();
    }
}

int SerialConnection::dataBits() const { return m_dataBits; }
void SerialConnection::setDataBits(int bits)
{
    // 设置数据位（通常为 5、6、7、8），值变化时发出通知
    if (m_dataBits != bits) {
        m_dataBits = bits;
        emit dataBitsChanged();
    }
}

QString SerialConnection::stopBits() const { return m_stopBits; }
void SerialConnection::setStopBits(const QString &bits)
{
    // 设置停止位（如 "1"、"1.5"、"2"），值变化时发出通知
    if (m_stopBits != bits) {
        m_stopBits = bits;
        emit stopBitsChanged();
    }
}

QString SerialConnection::parity() const { return m_parity; }
void SerialConnection::setParity(const QString &parity)
{
    // 设置校验位（如 None、Even、Odd），值变化时发出通知
    if (m_parity != parity) {
        m_parity = parity;
        emit parityChanged();
    }
}

bool SerialConnection::connected() const { return m_connected; }
QString SerialConnection::statusText() const { return m_statusText; }
QString SerialConnection::connectionType() const { return QStringLiteral("serial"); }

void SerialConnection::connect()
{
    // 建立串口连接，更新连接状态和状态文本
    if (!m_connected) {
        setConnected(true);
        setStatusText(QStringLiteral("已连接"));
    }
}

void SerialConnection::disconnect()
{
    // 断开串口连接，更新连接状态和状态文本
    if (m_connected) {
        setConnected(false);
        setStatusText(QStringLiteral("未连接"));
    }
}

void SerialConnection::setConnected(bool c)
{
    // 设置连接状态（已连接/未连接），值变化时发出通知
    if (m_connected != c) {
        m_connected = c;
        emit connectedChanged();
    }
}

void SerialConnection::setStatusText(const QString &text)
{
    // 设置状态文本信息，值变化时发出通知
    if (m_statusText != text) {
        m_statusText = text;
        emit statusTextChanged();
    }
}
