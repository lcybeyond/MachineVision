// ScriptManager.h
// 脚本引擎管理器，负责创建、管理和维护多个 AlgorithmScriptEngine 实例。
// 作为 QML 和 C++ 之间的桥梁，管理算法管理器、连接管理器、
// 全局变量管理器和日志记录器等依赖的注入与分发。

#ifndef SCRIPTMANAGER_H
#define SCRIPTMANAGER_H

#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include <AlgorithmScriptEngine.h>

class GlobalVariableManager;
class Logger;

class ScriptManager : public QObject
{
    Q_OBJECT
    // 当前管理的脚本引擎数量
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    // 算法管理器对象指针，用于在引擎间共享算法处理能力
    Q_PROPERTY(QObject* algorithmManager READ algorithmManager WRITE setAlgorithmManager
               NOTIFY algorithmManagerChanged)
    // 连接管理器对象指针，用于在引擎间共享设备连接（Modbus、串口等）
    Q_PROPERTY(QObject* connectionMgr READ connectionMgr WRITE setConnectionMgr
               NOTIFY connectionMgrChanged)
    // 全局变量管理器对象指针，用于在引擎间共享全局变量
    Q_PROPERTY(QObject* globalVariableManager READ globalVariableManager
               WRITE setGlobalVariableManager NOTIFY globalVariableManagerChanged)
    // 日志记录器对象指针，用于统一的日志输出
    Q_PROPERTY(QObject* logger READ logger WRITE setLogger NOTIFY loggerChanged)
    QML_ELEMENT

public:
    // 构造函数
    explicit ScriptManager(QObject *parent = nullptr);
    // 析构函数，释放所有管理的脚本引擎
    ~ScriptManager() override;

    // 返回当前管理的脚本引擎数量
    int count() const { return m_scriptEngines.size(); }

    // 获取当前算法管理器
    QObject* algorithmManager() const { return m_algoMgr; }
    // 设置算法管理器，并同步到所有已有脚本引擎
    void setAlgorithmManager(QObject *mgr);

    // 获取当前连接管理器
    QObject* connectionMgr() const { return m_connectionMgr; }
    // 设置连接管理器，并同步到所有已有脚本引擎
    void setConnectionMgr(QObject *mgr);

    // 获取全局变量管理器
    QObject* globalVariableManager() const;
    // 设置全局变量管理器
    void setGlobalVariableManager(QObject *mgr);

    // 获取日志记录器
    QObject* logger() const;
    // 设置日志记录器，并同步到所有已有脚本引擎
    void setLogger(QObject *mgr);

    // 创建一个新的 AlgorithmScriptEngine 实例并返回，自动注入已配置的依赖
    Q_INVOKABLE QObject* createEngine();
    // 移除并销毁指定索引位置的脚本引擎
    Q_INVOKABLE void removeEngineAt(int index);
    // 获取指定索引位置的脚本引擎
    Q_INVOKABLE QObject* engineAt(int index) const;
    // 确保脚本引擎数量至少达到 count，不足则自动创建
    Q_INVOKABLE void ensureCount(int count);

signals:
    // 当脚本引擎数量发生变化时发出
    void countChanged();
    // 当算法管理器发生变更时发出
    void algorithmManagerChanged();
    // 当连接管理器发生变更时发出
    void connectionMgrChanged();
    // 当全局变量管理器发生变更时发出
    void globalVariableManagerChanged();
    // 当日志记录器发生变更时发出
    void loggerChanged();

private:
    // 算法管理器
    QObject *m_algoMgr{nullptr};
    // 连接管理器
    QObject *m_connectionMgr{nullptr};
    // 全局变量管理器
    GlobalVariableManager *m_globalVarMgr{nullptr};
    // 日志记录器
    Logger *m_logger{nullptr};
    // 管理的脚本引擎列表
    QList<AlgorithmScriptEngine *> m_scriptEngines;
};

#endif // SCRIPTMANAGER_H
