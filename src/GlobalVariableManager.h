#ifndef GLOBALVARIABLEMANAGER_H
#define GLOBALVARIABLEMANAGER_H

// GlobalVariableManager — 全局变量管理器
// 管理可在 QML 前端与 C++ 后端之间共享的全局变量列表。
// 支持变量的增删查改以及文件的导入导出，变量变更时通知界面刷新。

#include <QObject>
#include <QVariant>
#include <QList>
#include <QtQml/qqmlregistration.h>

class GlobalVariableManager : public QObject
{
    Q_OBJECT
    // variables: 当前所有全局变量的列表，变量集合变更时发出通知
    Q_PROPERTY(QVariantList variables READ variables NOTIFY variablesChanged)
    QML_ELEMENT

public:
    // 构造函数，初始化全局变量管理器
    explicit GlobalVariableManager(QObject *parent = nullptr);

    // 返回当前所有变量组成的 QVariantList
    QVariantList variables() const;

    // 添加一个新变量，指定名称、类型和初始值
    Q_INVOKABLE void addVariable(const QString &name, const QString &type,
                                 const QVariant &value);
    // 按名称移除一个变量
    Q_INVOKABLE void removeVariable(const QString &name);
    // 按名称获取变量的完整信息（名称、类型、值），返回 QVariantMap
    Q_INVOKABLE QVariantMap getVariable(const QString &name) const;
    // 从指定 JSON 文件加载变量列表，覆盖当前所有变量
    Q_INVOKABLE void loadFromFile(const QString &path);
    // 将当前变量列表保存到指定 JSON 文件
    Q_INVOKABLE void saveToFile(const QString &path) const;

    // 将变量列表导出为可供脚本使用的 QVariantMap 格式
    QVariantMap toScriptValues() const;

signals:
    // 当变量列表发生变更（添加、删除、修改）时发出此信号
    void variablesChanged();

private:
    // 单个变量的内部存储结构
    struct Var {
        QString name;   // 变量名
        QString type;   // 变量类型
        QVariant value; // 变量值
    };
    QList<Var> m_variables;
};

#endif // GLOBALVARIABLEMANAGER_H
