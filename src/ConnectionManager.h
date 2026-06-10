#ifndef CONNECTIONMANAGER_H
#define CONNECTIONMANAGER_H

#include <QObject>
#include <QHash>
#include <QtQml/qqmlregistration.h>
#include <QVariant>
#include <QList>
#include "AbstractConnection.h"

class ConnectionManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList connections READ connections NOTIFY connectionsChanged)
    QML_ELEMENT

public:
    explicit ConnectionManager(QObject *parent = nullptr);
    ~ConnectionManager() override;

    QVariantList connections() const;

    Q_INVOKABLE QObject *createModbusTcp(const QString &name,
                                         const QString &ip,
                                         int port,
                                         int slaveId);
    Q_INVOKABLE QObject *createConnection(const QString &name, const QString &type,
                                           const QVariantMap &params);
    Q_INVOKABLE void removeConnection(const QString &name);
    Q_INVOKABLE QObject *connection(const QString &name) const;

signals:
    void connectionsChanged();

private:
    QHash<QString, AbstractConnection *> m_connections;
};

#endif // CONNECTIONMANAGER_H
