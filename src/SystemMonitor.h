// SystemMonitor.h
// 系统监控类，用于实时监控系统资源使用情况。
// 通过内部定时器定期采集系统指标（如内存占用），
// 并通过属性变更信号通知 QML 界面更新显示。

#ifndef SYSTEMMONITER_H
#define SYSTEMMONITER_H
#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class SystemMonitor : public QObject
{
    Q_OBJECT
    // 当前内存使用量（MB），由定时器定期刷新
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY memoryUsageChanged)
    QML_ELEMENT

public:
    // 构造函数，创建并启动定时器以定期采集系统指标
    explicit SystemMonitor(QObject *parent = nullptr);
    // 析构函数，使用默认实现
    ~SystemMonitor() override = default;

    // 获取当前内存使用量（MB）
    int memoryUsage() const { return m_memoryUsage; }

signals:
    // 当内存使用量更新时发出
    void memoryUsageChanged();

private slots:
    // 定时器回调，采集并更新系统指标（内存、CPU 等）
    void updateMetrics();

private:
    // 当前内存使用量，单位 MB
    int m_memoryUsage{0};
    // 定时器，按固定间隔触发系统指标采集
    QTimer *m_timer{nullptr};
};

#endif // SYSTEMMONITER_H
