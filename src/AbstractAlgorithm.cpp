#include "AbstractAlgorithm.h"

AbstractAlgorithm::AbstractAlgorithm(QObject *parent)
    : QObject(parent)
{
}

void AbstractAlgorithm::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}
