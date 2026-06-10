#include "AbstractConnection.h"

AbstractConnection::AbstractConnection(QObject *parent)
    : QObject(parent)
{
}

void AbstractConnection::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}
