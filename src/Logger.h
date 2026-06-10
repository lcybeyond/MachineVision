#ifndef LOGGER_H
#define LOGGER_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

class Logger : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
    QML_ELEMENT

public:
    explicit Logger(QObject *parent = nullptr);

    QString text() const;

    Q_INVOKABLE void clear();

public slots:
    void append(const QString &msg);

signals:
    void textChanged();
    void newLog(const QString &msg);

private:
    QString m_text;
};

#endif // LOGGER_H
