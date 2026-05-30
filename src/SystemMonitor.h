#ifndef SYSTEMMONITER_H
#define SYSTEMMONITER_H
#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class SystemMonitor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY memoryUsageChanged)
    QML_ELEMENT

public:
    explicit SystemMonitor(QObject *parent = nullptr);
    ~SystemMonitor() override = default;

    int memoryUsage() const { return m_memoryUsage; }

signals:
    void memoryUsageChanged();

private slots:
    void updateMetrics();

private:
    int m_memoryUsage{0};
    QTimer *m_timer{nullptr};
};

#endif // SYSTEMMONITER_H
