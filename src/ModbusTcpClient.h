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
    Q_PROPERTY(QString ipAddress READ ipAddress WRITE setIpAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(int port READ port WRITE setPort NOTIFY portChanged)
    Q_PROPERTY(int slaveId READ slaveId WRITE setSlaveId NOTIFY slaveIdChanged)

    // 连接状态（C++ → QML）
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)

    QML_ELEMENT

public:
    explicit ModbusTcpClient(QObject *parent = nullptr);
    ~ModbusTcpClient() override = default;

    QString ipAddress() const { return m_ipAddress; }
    void setIpAddress(const QString &ip);

    int port() const { return m_port; }
    void setPort(int port);

    int slaveId() const { return m_slaveId; }
    void setSlaveId(int id);

    bool connected() const override { return m_connected; }
    QString statusText() const override { return m_statusText; }
    QString connectionType() const override { return QStringLiteral("modbusTcp"); }

signals:
    void ipAddressChanged();
    void portChanged();
    void slaveIdChanged();


private:
    void setConnected(bool c);
    void setStatusText(const QString &text);


    QString m_ipAddress{"127.0.0.1"};
    int m_port{502};
    int m_slaveId{1};
    bool m_connected{false};
    QString m_statusText{"未连接"};
};

#endif // MODBUSTCPCLIENT_H
