// 文件: AlgorithmScriptEngine.cpp
// 功能: 实现 AlgorithmScriptEngine 类——算法脚本引擎，封装 QJSEngine，为 JS 脚本提供调用底层
//       算法、连接、全局变量、日志等 API 的能力

#include "AlgorithmScriptEngine.h"
#include "GlobalVariableManager.h"
#include "Logger.h"
#include <QJSEngine>
#include <QJSValue>
#include <QDebug>

// 构造函数：创建 QJSEngine 和 ScriptApi 实例，并初始化全局 JS 属性
AlgorithmScriptEngine::AlgorithmScriptEngine(QObject *parent)
    : QObject(parent)
    , m_engine(new QJSEngine(this))
    , m_api(new ScriptApi)
{
    setupEngine();
}

// 析构函数（默认实现）
AlgorithmScriptEngine::~AlgorithmScriptEngine() = default;

// 设置连接管理器，供脚本 API 调用连接相关功能
void AlgorithmScriptEngine::setConnectionMgr(QObject *mgr)
{
    m_api->setConnectionMgr(mgr);
}

// 设置算法管理器，供脚本 API 调用算法相关功能
void AlgorithmScriptEngine::setAlgorithmManager(QObject *mgr)
{
    m_api->setAlgorithmManager(mgr);
}

// 设置全局变量管理器，用于在脚本执行前注入全局变量
void AlgorithmScriptEngine::setGlobalVariableManager(GlobalVariableManager *mgr)
{
    m_globalVarMgr = mgr;
}

// 设置日志记录器，供脚本中 log/print 函数使用
void AlgorithmScriptEngine::setLogger(QObject *logger)
{
    m_api->setLogger(qobject_cast<Logger *>(logger));
}

// 设置日志前缀，用于区分不同脚本的输出
void AlgorithmScriptEngine::setLogPrefix(const QString &prefix)
{
    m_api->setLogPrefix(prefix);
}

// 初始化 JS 引擎：将 ScriptApi 的各方法注册为 JS 全局函数
void AlgorithmScriptEngine::setupEngine()
{
    m_api->setEngine(this);

    QJSValue global = m_engine->globalObject();

    QJSValue apiObj = m_engine->newQObject(m_api);

    // 注册连接/寄存器相关 JS 函数
    global.setProperty("readRegs",     apiObj.property("readRegs"));
    global.setProperty("writeReg",     apiObj.property("writeReg"));
    global.setProperty("writeRegs",    apiObj.property("writeRegs"));
    global.setProperty("isConnected",  apiObj.property("isConnected"));
    global.setProperty("connStatus",   apiObj.property("connStatus"));
    global.setProperty("connNames",    apiObj.property("connectionNames"));

    // 注册算法调用相关 JS 函数
    global.setProperty("callProcess",   apiObj.property("callProcess"));
    global.setProperty("algoNames",     apiObj.property("algorithmNames"));
    global.setProperty("algoTypes",     apiObj.property("algorithmTypes"));

    // 注册结果存取相关 JS 函数
    global.setProperty("setResult",    apiObj.property("setResult"));
    global.setProperty("getResult",    apiObj.property("getResult"));
    global.setProperty("clearResults", apiObj.property("clearResults"));

    // 注册采集/显示相关 JS 函数
    global.setProperty("capture",    apiObj.property("capture"));
    global.setProperty("showResult", apiObj.property("showResult"));
    global.setProperty("setVerdict", apiObj.property("setVerdict"));

    // 注册工具类 JS 函数
    global.setProperty("log",     apiObj.property("log"));
    global.setProperty("print",   apiObj.property("log"));
    global.setProperty("now",     apiObj.property("now"));
    global.setProperty("delay",   apiObj.property("delay"));
}

// 执行一段 JS 代码：注入全局变量后求值，返回结果
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

// 调用 JS 全局函数：按名称查找函数，传入参数列表并执行
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

// 检查 JS 全局作用域中是否存在指定名称的可调用函数
bool AlgorithmScriptEngine::hasFunction(const QString &funcName) const
{
    return m_engine->globalObject().property(funcName).isCallable();
}

// 中断当前正在执行的脚本
void AlgorithmScriptEngine::stop()
{
    m_engine->setInterrupted(true);
}

// 获取结果图像路径
QString AlgorithmScriptEngine::resultImageUrl() const
{
    return m_resultImageUrl;
}

// 设置结果图像路径，若变化则触发 resultImageUrlChanged 信号
void AlgorithmScriptEngine::setResultImageUrl(const QString &url)
{
    if (m_resultImageUrl != url) {
        m_resultImageUrl = url;
        emit resultImageUrlChanged();
    }
}

// 获取判定结果（OK/NG）
QString AlgorithmScriptEngine::verdict() const
{
    return m_verdict;
}

// 设置判定结果，若变化则触发 verdictChanged 信号
void AlgorithmScriptEngine::setVerdict(const QString &v)
{
    if (m_verdict != v) {
        m_verdict = v;
        emit verdictChanged();
    }
}
