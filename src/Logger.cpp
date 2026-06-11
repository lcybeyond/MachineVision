// Logger.cpp - 日志记录器实现
// 提供带时间戳的日志追加功能，支持状态消息管理和日志清空操作。
// 用于在界面中实时显示运行日志和状态信息。

#include "Logger.h"
#include <QDateTime>

Logger::Logger(QObject *parent)
    : QObject(parent)
{
}

// 获取当前完整的日志文本
QString Logger::text() const
{
    return m_text;
}

// 清空所有日志内容
// 清空日志文本并发射变更信号，通知 UI 刷新
void Logger::clear()
{
    m_text.clear();
    emit textChanged();
}

// 获取当前状态文本
QString Logger::statusText() const
{
    return m_statusText;
}

// 设置状态栏消息
// 仅在消息变化时更新并发射信号，避免不必要的 UI 刷新
void Logger::setStatus(const QString &msg)
{
    if (m_statusText != msg) {
        m_statusText = msg;
        emit statusTextChanged();
    }
}

// 追加一条带时间戳的日志记录
// 自动添加 HH:mm:ss 格式的时间前缀，每条日志独占一行
void Logger::append(const QString &msg)
{
    QString ts = QDateTime::currentDateTime().toString("HH:mm:ss");
    QString line = QString("[%1] %2").arg(ts, msg);
    m_text += line + "\n";
    emit newLog(line);
    emit textChanged();
}
