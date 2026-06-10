#include "ConnectionManager.h"
#include "ModbusTcpClient.h"
#include <QDebug>

ConnectionManager::ConnectionManager(QObject *parent)
    : QObject(parent)
{
}

ConnectionManager::~ConnectionManager()
{
    qDeleteAll(m_connections);
}

QVariantList ConnectionManager::connections() const
{
    QVariantList list;
    for (auto *conn : m_connections)
        list.append(QVariant::fromValue(static_cast<QObject *>(conn)));
    return list;
}

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

    qWarning() << "ConnectionManager: 未知类型" << type;
    return nullptr;
}

void ConnectionManager::removeConnection(const QString &name)
{
    if (auto *conn = m_connections.take(name)) {
        conn->deleteLater();
        emit connectionsChanged();
    }
}

QObject *ConnectionManager::connection(const QString &name) const
{
    return m_connections.value(name, nullptr);
}

