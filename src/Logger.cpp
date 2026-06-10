#include "Logger.h"
#include <QDateTime>

Logger::Logger(QObject *parent)
    : QObject(parent)
{
}

QString Logger::text() const
{
    return m_text;
}

void Logger::clear()
{
    m_text.clear();
    emit textChanged();
}

QString Logger::statusText() const
{
    return m_statusText;
}

void Logger::setStatus(const QString &msg)
{
    if (m_statusText != msg) {
        m_statusText = msg;
        emit statusTextChanged();
    }
}

void Logger::append(const QString &msg)
{
    QString ts = QDateTime::currentDateTime().toString("HH:mm:ss");
    QString line = QString("[%1] %2").arg(ts, msg);
    m_text += line + "\n";
    emit newLog(line);
    emit textChanged();
}
