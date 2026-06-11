#ifndef LOGGER_H
#define LOGGER_H

// Logger — 应用程序日志管理器
// QML 单例，负责收集、存储和分发应用程序运行日志。
// 提供日志追加、清空和状态设置功能，日志内容变化时通知界面更新。

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QJSEngine>
#include <QQmlEngine>

class Logger : public QObject
{
    Q_OBJECT
    // text: 当前完整的日志文本内容，日志变更时发出通知
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
    // statusText: 当前状态栏文本，状态更新时发出通知
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    QML_ELEMENT
    QML_SINGLETON

public:

    // 构造函数，初始化日志管理器
    explicit Logger(QObject *parent = nullptr);

    // 返回当前全部日志文本
    QString text() const;
    // 返回当前状态栏文本
    QString statusText() const;

    // 清空所有日志内容
    Q_INVOKABLE void clear();
    // 设置状态栏文本信息
    Q_INVOKABLE void setStatus(const QString &msg);

public slots:
    // 向日志末尾追加一条新消息
    void append(const QString &msg);

signals:
    // 当日志文本内容增加（或清空）时发出此信号
    void textChanged();
    // 每当有新的日志消息追加时发出此信号，携带新消息内容
    void newLog(const QString &msg);
    // 当状态栏文本发生变化时发出此信号
    void statusTextChanged();

private:
    QString m_text;
    QString m_statusText;
};

#endif // LOGGER_H
