#include "ScriptManager.h"
#include "AlgorithmScriptEngine.h"

ScriptManager::ScriptManager(QObject *parent)
    : QObject(parent)
{
}

ScriptManager::~ScriptManager()
{
    qDeleteAll(m_scriptEngines);
}

void ScriptManager::setAlgorithmManager(QObject *mgr)
{
    if (m_algoMgr != mgr) {
        m_algoMgr = mgr;
        for (auto *e : m_scriptEngines)
            e->setAlgorithmManager(mgr);
        emit algorithmManagerChanged();
    }
}

void ScriptManager::setConnectionMgr(QObject *mgr)
{
    if (m_connectionMgr != mgr) {
        m_connectionMgr = mgr;
        for (auto *e : m_scriptEngines)
            e->setConnectionMgr(mgr);
        emit connectionMgrChanged();
    }
}

QObject* ScriptManager::createEngine()
{
    auto *engine = new AlgorithmScriptEngine(this);
    if (m_algoMgr)
        engine->setAlgorithmManager(m_algoMgr);
    if (m_connectionMgr)
        engine->setConnectionMgr(m_connectionMgr);

    m_scriptEngines.append(engine);
    emit countChanged();
    return engine;
}

void ScriptManager::removeEngineAt(int index)
{
    if (index >= 0 && index < m_scriptEngines.size()) {
        delete m_scriptEngines.takeAt(index);
        emit countChanged();
    }
}

QObject* ScriptManager::engineAt(int index) const
{
    if (index >= 0 && index < m_scriptEngines.size())
        return m_scriptEngines[index];
    return nullptr;
}

void ScriptManager::ensureCount(int count)
{
    while (m_scriptEngines.size() < count)
        createEngine();
    while (m_scriptEngines.size() > count)
        delete m_scriptEngines.takeLast();
    emit countChanged();
}
