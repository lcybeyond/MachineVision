// 文件: ConnectionManager.cpp
// 功能: 实现 ConnectionManager 类——连接管理器，负责各类连接（Modbus TCP、串口、相机等）
//       的创建、删除和查询

#include "ConnectionManager.h"
#include "ModbusTcpClient.h"
#include "SerialConnection.h"
#include "CameraConnection.h"
#include <QDebug>

// 构造函数：初始化连接管理器
ConnectionManager::ConnectionManager(QObject *parent)
    : QObject(parent)
{
}

// 析构函数：释放所有连接对象
ConnectionManager::~ConnectionManager()
{
    qDeleteAll(m_connections);
}

// 获取所有连接的列表，以 QVariantList 形式返回，供 QML 侧使用
QVariantList ConnectionManager::connections() const
{
    QVariantList list;
    for (auto *conn : m_connections)
        list.append(QVariant::fromValue(static_cast<QObject *>(conn)));
    return list;
}

// 创建 Modbus TCP 连接：指定名称、IP、端口和从站 ID
QObject *ConnectionManager::createModbusTcp(const QString &name,
                                            const QString &ip,
                                            int port,
                                            int slaveId)
{
    if (m_connections.contains(name)) {
        qWarning() << "ConnectionManager: 名称" << name << "已存在";
        return nullptr;
    }

    auto *client = new ModbusTcpClient(this);
    client->setName(name);
    client->setIpAddress(ip);
    client->setPort(port);
    client->setSlaveId(slaveId);

    m_connections.insert(name, client);
    emit connectionsChanged();
    return client;
}

// 根据类型和参数创建连接：支持 modbusTcp、serial、camera 三种类型
QObject *ConnectionManager::createConnection(const QString &name,
                                            const QString &type,
                                            const QVariantMap &params)
{
    if (m_connections.contains(name)) {
        qWarning() << "ConnectionManager: 名称" << name << "已存在";
        return nullptr;
    }

    if (type == "modbusTcp") {
        return createModbusTcp(name,
                               params.value("ip").toString(),
                               params.value("port").toInt(),
                               params.value("slaveId").toInt());
    }

    if (type == "serial") {
        auto *conn = new SerialConnection(this);
        conn->setName(name);
        conn->setPort(params.value("port", "COM1").toString());
        conn->setBaudRate(params.value("baudRate", 115200).toInt());
        conn->setDataBits(params.value("dataBits", 8).toInt());
        conn->setStopBits(params.value("stopBits", "1").toString());
        conn->setParity(params.value("parity", "None").toString());
        m_connections.insert(name, conn);
        emit connectionsChanged();
        return conn;
    }

    if (type == "camera") {
        auto *conn = new CameraConnection(this);
        conn->setName(name);
        m_connections.insert(name, conn);
        emit connectionsChanged();
        return conn;
    }

    qWarning() << "ConnectionManager: 未知类型" << type;
    return nullptr;
}

// 根据名称删除指定的连接
void ConnectionManager::removeConnection(const QString &name)
{
    if (auto *conn = m_connections.take(name)) {
        conn->deleteLater();
        emit connectionsChanged();
    }
}

// 根据名称查找并返回连接对象
QObject *ConnectionManager::connection(const QString &name) const
{
    return m_connections.value(name, nullptr);
}
