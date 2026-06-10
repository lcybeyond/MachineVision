#ifndef ABSTRACTCONNECTION_H
#define ABSTRACTCONNECTION_H

#include <QObject>

class AbstractConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    Q_PROPERTY(QString connectionType READ connectionType CONSTANT)

public:
    explicit AbstractConnection(QObject *parent = nullptr);

    QString name() const { return m_name; }
    void setName(const QString &name);

    virtual bool connected() const = 0;
    virtual QString statusText() const = 0;
    virtual QString connectionType() const = 0;

signals:
    void nameChanged();
    void connectedChanged();
    void statusTextChanged();

protected:
    QString m_name;
};


#endif // ABSTRACTCONNECTION_H
