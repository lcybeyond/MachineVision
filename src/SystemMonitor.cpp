// SystemMonitor.cpp —— 系统监控实现
// 通过 macOS 原生 Mach API 获取系统内存使用率，每秒刷新一次并通过 QML 属性通知界面更新
#include "SystemMonitor.h"
#include <QDebug>

// macOS 原生底层头文件
#include <mach/mach.h>
#include <mach/mach_host.h>
#include <sys/sysctl.h>
#include <unistd.h>

SystemMonitor::SystemMonitor(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
{
    // 构造函数：创建定时器，每秒触发一次内存指标更新
    connect(m_timer, &QTimer::timeout, this, &SystemMonitor::updateMetrics);
    m_timer->start(1000); // 每秒刷新

    updateMetrics(); // 初始化运行一次
}

void SystemMonitor::updateMetrics()
{
    // 通过 macOS 内核 Mach API 获取虚拟内存统计数据，计算内存使用百分比
    // 使用公式：内存使用率 = (活跃页 + 联动页 + 投机页) / 总页数 × 100%
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;

    vm_statistics64_data_t vmStats;

    mach_port_t host_port = mach_host_self();

    // 从 macOS 内核获取虚拟内存统计信息
    if (host_statistics64(host_port, HOST_VM_INFO64, (host_info64_t)&vmStats, &count) == KERN_SUCCESS) {

        // 1. 计算已使用的内存页数
        // 包含：active(活跃), speculative(投机), wire(联动/系统核心常驻)
        // 注意：macOS 的 compressed(压缩内存) 在标准计算中常被算入 wire 或 active
        int64_t usedPages = vmStats.active_count +
                            vmStats.wire_count +
                            vmStats.speculative_count;

        // 2. 计算总内存页数（已用页 + 空闲页 + 不活跃页）
        int64_t totalPages = usedPages +
                             vmStats.free_count +
                             vmStats.inactive_count;

        if (totalPages > 0) {
            // 计算百分比
            int currentUsage = static_cast<int>((usedPages * 100) / totalPages);

            // 限定在 0-100 范围内
            currentUsage = std::max(0, std::min(100, currentUsage));

            // 数据变化时通知 QML
            if (m_memoryUsage != currentUsage) {
                m_memoryUsage = currentUsage;
                emit memoryUsageChanged();
            }
        }
    } else {
        qWarning() << "Failed to fetch macOS host_statistics64.";
    }
}
