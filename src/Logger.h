#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QJSEngine>
#include <QQmlEngine>

class Logger : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    QML_ELEMENT
    QML_SINGLETON

public:

    explicit Logger(QObject *parent = nullptr);

    QString text() const;
    QString statusText() const;

    Q_INVOKABLE void clear();
    Q_INVOKABLE void setStatus(const QString &msg);

public slots:
    void append(const QString &msg);

signals:
    void textChanged();
    void newLog(const QString &msg);
    void statusTextChanged();

private:
    QString m_text;
    QString m_statusText;
};

#endif // LOGGER_H
