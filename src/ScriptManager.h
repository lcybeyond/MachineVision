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
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QObject* algorithmManager READ algorithmManager WRITE setAlgorithmManager
               NOTIFY algorithmManagerChanged)
    Q_PROPERTY(QObject* connectionMgr READ connectionMgr WRITE setConnectionMgr
               NOTIFY connectionMgrChanged)
    Q_PROPERTY(QObject* globalVariableManager READ globalVariableManager
               WRITE setGlobalVariableManager NOTIFY globalVariableManagerChanged)
    Q_PROPERTY(QObject* logger READ logger WRITE setLogger NOTIFY loggerChanged)
    QML_ELEMENT

public:
    explicit ScriptManager(QObject *parent = nullptr);
    ~ScriptManager() override;

    int count() const { return m_scriptEngines.size(); }

    QObject* algorithmManager() const { return m_algoMgr; }
    void setAlgorithmManager(QObject *mgr);

    QObject* connectionMgr() const { return m_connectionMgr; }
    void setConnectionMgr(QObject *mgr);

    QObject* globalVariableManager() const;
    void setGlobalVariableManager(QObject *mgr);

    QObject* logger() const;
    void setLogger(QObject *mgr);

    Q_INVOKABLE QObject* createEngine();
    Q_INVOKABLE void removeEngineAt(int index);
    Q_INVOKABLE QObject* engineAt(int index) const;
    Q_INVOKABLE void ensureCount(int count);

signals:
    void countChanged();
    void algorithmManagerChanged();
    void connectionMgrChanged();
    void globalVariableManagerChanged();
    void loggerChanged();

private:
    QObject *m_algoMgr{nullptr};
    QObject *m_connectionMgr{nullptr};
    GlobalVariableManager *m_globalVarMgr{nullptr};
    Logger *m_logger{nullptr};
    QList<AlgorithmScriptEngine *> m_scriptEngines;
};

#endif // SCRIPTMANAGER_H
