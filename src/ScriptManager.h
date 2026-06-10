#ifndef SCRIPTMANAGER_H
#define SCRIPTMANAGER_H

#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include <AlgorithmScriptEngine.h>


class ScriptManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QObject* algorithmManager READ algorithmManager WRITE setAlgorithmManager
               NOTIFY algorithmManagerChanged)
    Q_PROPERTY(QObject* connectionMgr READ connectionMgr WRITE setConnectionMgr
               NOTIFY connectionMgrChanged)
    QML_ELEMENT

public:
    explicit ScriptManager(QObject *parent = nullptr);
    ~ScriptManager() override;

    int count() const { return m_scriptEngines.size(); }

    QObject* algorithmManager() const { return m_algoMgr; }
    void setAlgorithmManager(QObject *mgr);

    QObject* connectionMgr() const { return m_connectionMgr; }
    void setConnectionMgr(QObject *mgr);

    Q_INVOKABLE QObject* createEngine();
    Q_INVOKABLE void removeEngineAt(int index);
    Q_INVOKABLE QObject* engineAt(int index) const;
    Q_INVOKABLE void ensureCount(int count);

signals:
    void countChanged();
    void algorithmManagerChanged();
    void connectionMgrChanged();

private:
    QObject *m_algoMgr{nullptr};
    QObject *m_connectionMgr{nullptr};
    QList<AlgorithmScriptEngine *> m_scriptEngines;
};

#endif // SCRIPTMANAGER_H
