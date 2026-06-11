#ifndef ABSTRACTCONNECTION_H
#define ABSTRACTCONNECTION_H

#include <QObject>

// 连接抽象基类，定义所有设备连接的通用接口。
// 子类必须实现 connected()、statusText()、connectionType()、connect() 和 disconnect()。
class AbstractConnection : public QObject
{
    Q_OBJECT
    // 连接名称，可通过 QML 绑定读写
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    // 连接状态，true 表示已连接，false 表示未连接
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    // 连接状态的文本描述，用于 UI 显示
    Q_PROPERTY(QString statusText READ statusText NOTIFY statusTextChanged)
    // 连接类型标识（常量），由子类实现，创建后不可更改
    Q_PROPERTY(QString connectionType READ connectionType CONSTANT)

public:
    // 构造函数
    // @param parent 父对象指针
    explicit AbstractConnection(QObject *parent = nullptr);

    // 获取连接名称
    QString name() const { return m_name; }
    // 设置连接名称，修改后发射 nameChanged 信号
    void setName(const QString &name);

    // 纯虚函数，返回当前是否已连接
    virtual bool connected() const = 0;
    // 纯虚函数，返回连接状态的文本描述
    virtual QString statusText() const = 0;
    // 纯虚函数，返回连接类型标识字符串
    virtual QString connectionType() const = 0;

    // 发起连接（可在 QML 中调用）
    Q_INVOKABLE virtual void connect() = 0;
    // 断开连接（可在 QML 中调用）
    Q_INVOKABLE virtual void disconnect() = 0;

signals:
    // 当连接名称变更时发射
    void nameChanged();
    // 当连接状态变更时发射
    void connectedChanged();
    // 当连接状态文本变更时发射
    void statusTextChanged();

protected:
    // 连接名称
    QString m_name;
};


#endif // ABSTRACTCONNECTION_H
