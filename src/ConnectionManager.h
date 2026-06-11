#ifndef CONNECTIONMANAGER_H
#define CONNECTIONMANAGER_H

#include <QObject>
#include <QHash>
#include <QtQml/qqmlregistration.h>
#include <QVariant>
#include <QList>
#include "AbstractConnection.h"

// 连接管理器，负责设备连接的生命周期管理，包括创建、删除和查询。
// 注册为 QML 元素，可在 QML 中直接使用。
class ConnectionManager : public QObject
{
    Q_OBJECT
    // 当前所有连接对象的列表
    Q_PROPERTY(QVariantList connections READ connections NOTIFY connectionsChanged)
    // 注册为 QML 可用元素
    QML_ELEMENT

public:
    // 构造函数
    // @param parent 父对象指针
    explicit ConnectionManager(QObject *parent = nullptr);
    // 析构函数，释放所有管理的连接对象
    ~ConnectionManager() override;

    // 获取当前所有连接对象的列表
    QVariantList connections() const;

    // 创建 Modbus TCP 连接（可在 QML 中调用）
    // @param name 连接名称
    // @param ip 设备 IP 地址
    // @param port 端口号
    // @param slaveId 从站 ID
    // @return 创建的连接对象指针
    Q_INVOKABLE QObject *createModbusTcp(const QString &name,
                                         const QString &ip,
                                         int port,
                                         int slaveId);
    // 创建指定类型的连接（可在 QML 中调用）
    // @param name 连接名称
    // @param type 连接类型
    // @param params 连接参数键值对
    // @return 创建的连接对象指针
    Q_INVOKABLE QObject *createConnection(const QString &name, const QString &type,
                                           const QVariantMap &params);
    // 按名称移除连接（可在 QML 中调用）
    // @param name 要移除的连接名称
    Q_INVOKABLE void removeConnection(const QString &name);
    // 按名称查找连接（可在 QML 中调用）
    // @param name 连接名称
    // @return 连接对象指针，未找到返回 nullptr
    Q_INVOKABLE QObject *connection(const QString &name) const;

signals:
    // 当连接列表发生变更（新增或删除）时发射
    void connectionsChanged();

private:
    // 连接对象哈希表，key 为连接名称，value 为连接对象指针
    QHash<QString, AbstractConnection *> m_connections;
};

#endif // CONNECTIONMANAGER_H
