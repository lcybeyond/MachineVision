// ScriptManager.cpp —— 脚本引擎管理器实现
// 负责创建、管理和销毁多个 AlgorithmScriptEngine 实例，统一分配算法管理器、连接管理器、全局变量管理器和日志记录器
#include "ScriptManager.h"
#include "AlgorithmScriptEngine.h"
#include "GlobalVariableManager.h"
#include "Logger.h"

ScriptManager::ScriptManager(QObject *parent)
    : QObject(parent)
{
    // 构造函数：初始化 QObject 基类
}

ScriptManager::~ScriptManager()
{
    // 析构函数：释放所有脚本引擎实例
    qDeleteAll(m_scriptEngines);
}

void ScriptManager::setAlgorithmManager(QObject *mgr)
{
    // 设置算法管理器，并向所有已创建的脚本引擎同步传递
    if (m_algoMgr != mgr) {
        m_algoMgr = mgr;
        for (auto *e : m_scriptEngines)
            e->setAlgorithmManager(mgr);
        emit algorithmManagerChanged();
    }
}

void ScriptManager::setConnectionMgr(QObject *mgr)
{
    // 设置连接管理器，并向所有已创建的脚本引擎同步传递
    if (m_connectionMgr != mgr) {
        m_connectionMgr = mgr;
        for (auto *e : m_scriptEngines)
            e->setConnectionMgr(mgr);
        emit connectionMgrChanged();
    }
}

QObject *ScriptManager::globalVariableManager() const
{
    // 获取当前绑定的全局变量管理器
    return m_globalVarMgr;
}

void ScriptManager::setGlobalVariableManager(QObject *mgr)
{
    // 设置全局变量管理器，并向所有已创建的脚本引擎同步传递
    auto *gvm = qobject_cast<GlobalVariableManager *>(mgr);
    if (m_globalVarMgr != gvm) {
        m_globalVarMgr = gvm;
        for (auto *e : m_scriptEngines)
            e->setGlobalVariableManager(gvm);
        emit globalVariableManagerChanged();
    }
}

QObject* ScriptManager::logger() const
{
    // 获取当前绑定的日志记录器
    return m_logger;
}

void ScriptManager::setLogger(QObject *mgr)
{
    // 设置日志记录器，并向所有已创建的脚本引擎同步传递
    auto *l = qobject_cast<Logger *>(mgr);
    if (m_logger != l) {
        m_logger = l;
        for (auto *e : m_scriptEngines)
            e->setLogger(l);
        emit loggerChanged();
    }
}

QObject* ScriptManager::createEngine()
{
    // 创建新的 AlgorithmScriptEngine 实例
    // 自动将当前已设置的管理器（算法、连接、全局变量、日志）注入新引擎
    auto *engine = new AlgorithmScriptEngine(this);
    if (m_algoMgr)
        engine->setAlgorithmManager(m_algoMgr);
    if (m_connectionMgr)
        engine->setConnectionMgr(m_connectionMgr);
    if (m_globalVarMgr)
        engine->setGlobalVariableManager(m_globalVarMgr);
    if (m_logger)
        engine->setLogger(m_logger);

    m_scriptEngines.append(engine);
    emit countChanged();
    return engine;
}

void ScriptManager::removeEngineAt(int index)
{
    // 移除并销毁指定索引位置的脚本引擎
    if (index >= 0 && index < m_scriptEngines.size()) {
        delete m_scriptEngines.takeAt(index);
        emit countChanged();
    }
}

QObject* ScriptManager::engineAt(int index) const
{
    // 获取指定索引位置的脚本引擎指针
    // 索引越界时返回 nullptr
    if (index >= 0 && index < m_scriptEngines.size())
        return m_scriptEngines[index];
    return nullptr;
}

void ScriptManager::ensureCount(int count)
{
    // 确保脚本引擎数量达到指定值
    // 数量不足时创建新引擎，数量超出时销毁多余引擎
    while (m_scriptEngines.size() < count)
        createEngine();
    while (m_scriptEngines.size() > count)
        delete m_scriptEngines.takeLast();
    emit countChanged();
}
