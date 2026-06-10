#ifndef ALGORITHMSCRIPTENGINE_H
#define ALGORITHMSCRIPTENGINE_H

#include <QObject>
#include <QVariant>
#include <QJSEngine>
#include <ScriptApi.h>

class GlobalVariableManager;

class AlgorithmScriptEngine : public QObject
{
    Q_OBJECT

public:
    explicit AlgorithmScriptEngine(QObject *parent = nullptr);
    ~AlgorithmScriptEngine() override;

    void setConnectionMgr(QObject *mgr);
    void setAlgorithmManager(QObject *mgr);
    void setGlobalVariableManager(GlobalVariableManager *mgr);
    void setLogger(QObject *logger);

    Q_INVOKABLE void setLogPrefix(const QString &prefix);

    Q_INVOKABLE QVariant evaluate(const QString &code);
    Q_INVOKABLE QVariant callFunction(const QString &funcName,
                                      const QVariantList &args);
    Q_INVOKABLE bool hasFunction(const QString &funcName) const;
    Q_INVOKABLE void stop();

signals:
    void scriptError(const QString &message);
    void scriptOutput(const QString &message);

private:
    void setupEngine();
    QJSEngine *m_engine{nullptr};
    ScriptApi *m_api{nullptr};
    GlobalVariableManager *m_globalVarMgr{nullptr};
    QStringList m_injectedVarNames;
};

#endif // ALGORITHMSCRIPTENGINE_H
