#include "AlgorithmScriptEngine.h"
#include "GlobalVariableManager.h"
#include "Logger.h"
#include <QJSEngine>
#include <QJSValue>
#include <QDebug>

AlgorithmScriptEngine::AlgorithmScriptEngine(QObject *parent)
    : QObject(parent)
    , m_engine(new QJSEngine(this))
    , m_api(new ScriptApi)
{
    setupEngine();
}

AlgorithmScriptEngine::~AlgorithmScriptEngine() = default;

void AlgorithmScriptEngine::setConnectionMgr(QObject *mgr)
{
    m_api->setConnectionMgr(mgr);
}

void AlgorithmScriptEngine::setAlgorithmManager(QObject *mgr)
{
    m_api->setAlgorithmManager(mgr);
}

void AlgorithmScriptEngine::setGlobalVariableManager(GlobalVariableManager *mgr)
{
    m_globalVarMgr = mgr;
}

void AlgorithmScriptEngine::setLogger(QObject *logger)
{
    m_api->setLogger(qobject_cast<Logger *>(logger));
}

void AlgorithmScriptEngine::setLogPrefix(const QString &prefix)
{
    m_api->setLogPrefix(prefix);
}

void AlgorithmScriptEngine::setupEngine()
{
    QJSValue global = m_engine->globalObject();

    QJSValue apiObj = m_engine->newQObject(m_api);

    global.setProperty("readRegs",     apiObj.property("readRegs"));
    global.setProperty("writeReg",     apiObj.property("writeReg"));
    global.setProperty("writeRegs",    apiObj.property("writeRegs"));
    global.setProperty("isConnected",  apiObj.property("isConnected"));
    global.setProperty("connStatus",   apiObj.property("connStatus"));
    global.setProperty("connNames",    apiObj.property("connectionNames"));

    global.setProperty("callProcess",   apiObj.property("callProcess"));
    global.setProperty("algoNames",     apiObj.property("algorithmNames"));
    global.setProperty("algoTypes",     apiObj.property("algorithmTypes"));

    global.setProperty("setResult",    apiObj.property("setResult"));
    global.setProperty("getResult",    apiObj.property("getResult"));
    global.setProperty("clearResults", apiObj.property("clearResults"));

    global.setProperty("log",     apiObj.property("log"));
    global.setProperty("print",   apiObj.property("log"));
    global.setProperty("now",     apiObj.property("now"));
    global.setProperty("delay",   apiObj.property("delay"));
}

QVariant AlgorithmScriptEngine::evaluate(const QString &code)
{
    QJSValue global = m_engine->globalObject();

    // 清除上一次注入的变量
    for (const QString &name : m_injectedVarNames)
        global.deleteProperty(name);
    m_injectedVarNames.clear();

    // 注入当前全局变量
    if (m_globalVarMgr) {
        QVariantMap vars = m_globalVarMgr->toScriptValues();
        for (auto it = vars.begin(); it != vars.end(); ++it) {
            global.setProperty(it.key(), m_engine->toScriptValue(it.value()));
            m_injectedVarNames.append(it.key());
        }
    }

    QJSValue result = m_engine->evaluate(code);
    if (result.isError()) {
        QString err = QString("Line %1: %2")
        .arg(result.property("lineNumber").toInt())
            .arg(result.toString());
        emit scriptError(err);
        return QVariant();
    }
    emit scriptOutput(result.toString());
    return result.toVariant();
}

QVariant AlgorithmScriptEngine::callFunction(const QString &funcName,
                                             const QVariantList &args)
{
    QJSValue func = m_engine->globalObject().property(funcName);
    if (!func.isCallable()) {
        emit scriptError(QString("Function '%1' not found").arg(funcName));
        return QVariant();
    }

    QJSValueList jsArgs;
    for (const QVariant &v : args)
        jsArgs.append(m_engine->toScriptValue(v));

    QJSValue result = func.call(jsArgs);
    if (result.isError()) {
        emit scriptError(result.toString());
        return QVariant();
    }
    return result.toVariant();
}

bool AlgorithmScriptEngine::hasFunction(const QString &funcName) const
{
    return m_engine->globalObject().property(funcName).isCallable();
}

void AlgorithmScriptEngine::stop()
{
    m_engine->setInterrupted(true);
}
