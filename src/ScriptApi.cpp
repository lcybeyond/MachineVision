#include "ScriptApi.h"
#include <QMetaObject>
#include <QDebug>
#include <QThread>
#include <QDateTime>

ScriptApi::ScriptApi(QObject *parent)
    : QObject(parent)
{
}

void ScriptApi::setConnectionMgr(QObject *mgr)
{
    m_connMgr = mgr;
}

void ScriptApi::setAlgorithmManager(QObject *mgr)
{
    m_algoMgr = mgr;
}

// ========== 内部辅助 ==========

QObject* ScriptApi::findConnection(const QString &name) const
{
    if (!m_connMgr) return nullptr;

    QObject *conn = nullptr;
    QMetaObject::invokeMethod(m_connMgr, "connection",
        Q_RETURN_ARG(QObject*, conn),
        Q_ARG(QString, name));
    return conn;
}

QObject* ScriptApi::findAlgorithm(const QString &name) const
{
    if (!m_algoMgr) return nullptr;

    QObject *algo = nullptr;
    QMetaObject::invokeMethod(m_algoMgr, "algorithm",
        Q_RETURN_ARG(QObject*, algo),
        Q_ARG(QString, name));
    return algo;
}

// ========== 核心算法调用 ==========

QVariantMap ScriptApi::callProcess(const QString &algoName,
                                    const QVariantMap &input)
{
    auto *algo = findAlgorithm(algoName);
    if (!algo) {
        log("错误: 算法 '" + algoName + "' 不存在");
        return {{"ok", false}, {"error", "算法不存在: " + algoName}};
    }

    QVariant ret;
    bool ok = QMetaObject::invokeMethod(algo, "process",
        Q_RETURN_ARG(QVariant, ret),
        Q_ARG(QVariantMap, input));

    if (!ok) {
        log("错误: 调用 '" + algoName + ".process' 失败");
        return {{"ok", false}, {"error", "process 调用失败"}};
    }

    return ret.toMap();
}

QStringList ScriptApi::algorithmNames() const
{
    if (!m_algoMgr) return {};

    QVariant ret;
    QMetaObject::invokeMethod(m_algoMgr, "algorithms",
        Q_RETURN_ARG(QVariant, ret));

    QStringList names;
    for (const auto &v : ret.toList()) {
        QObject *algo = v.value<QObject *>();
        if (algo) {
            QVariant n;
            QMetaObject::invokeMethod(algo, "name",
                Q_RETURN_ARG(QVariant, n));
            names.append(n.toString());
        }
    }
    return names;
}

QStringList ScriptApi::algorithmTypes() const
{
    if (!m_algoMgr) return {};

    QVariant ret;
    QMetaObject::invokeMethod(m_algoMgr, "algorithmTypes",
        Q_RETURN_ARG(QVariant, ret));
    return ret.toStringList();
}

// ========== 连接查询 ==========

QVariantList ScriptApi::readRegs(const QString &connName, int addr, int count)
{
    auto *conn = findConnection(connName);
    if (!conn) {
        log("错误: 连接 '" + connName + "' 不存在");
        return {};
    }

    QVariant ret;
    QMetaObject::invokeMethod(conn, "readRegisters",
        Q_RETURN_ARG(QVariant, ret),
        Q_ARG(int, addr), Q_ARG(int, count));
    return ret.toList();
}

void ScriptApi::writeReg(const QString &connName, int addr, int value)
{
    writeRegs(connName, addr, {value});
}

void ScriptApi::writeRegs(const QString &connName, int addr,
                           const QVariantList &values)
{
    auto *conn = findConnection(connName);
    if (!conn) {
        log("错误: 连接 '" + connName + "' 不存在");
        return;
    }

    QMetaObject::invokeMethod(conn, "writeRegisters",
        Q_ARG(int, addr), Q_ARG(QVariantList, values));
}

bool ScriptApi::isConnected(const QString &connName)
{
    auto *conn = findConnection(connName);
    if (!conn) return false;

    QVariant ret;
    QMetaObject::invokeMethod(conn, "connected",
        Q_RETURN_ARG(QVariant, ret));
    return ret.toBool();
}

QString ScriptApi::connStatus(const QString &connName)
{
    auto *conn = findConnection(connName);
    if (!conn) return "不存在";

    QVariant ret;
    QMetaObject::invokeMethod(conn, "statusText",
        Q_RETURN_ARG(QVariant, ret));
    return ret.toString();
}

QStringList ScriptApi::connectionNames() const
{
    if (!m_connMgr) return {};

    QVariant ret;
    QMetaObject::invokeMethod(m_connMgr, "connections",
        Q_RETURN_ARG(QVariant, ret));

    QStringList names;
    for (const auto &v : ret.toList()) {
        QObject *conn = v.value<QObject *>();
        if (conn) {
            QVariant n;
            QMetaObject::invokeMethod(conn, "name",
                Q_RETURN_ARG(QVariant, n));
            names.append(n.toString());
        }
    }
    return names;
}

// ========== 结果存取 ==========

void ScriptApi::setResult(const QString &key, const QVariant &value)
{
    m_results[key] = value;
}

QVariant ScriptApi::getResult(const QString &key) const
{
    return m_results.value(key);
}

void ScriptApi::clearResults()
{
    m_results.clear();
}

// ========== 工具 ==========

void ScriptApi::log(const QString &msg)
{
    qDebug().noquote() << "[Script]" << msg;
}

qint64 ScriptApi::now() const
{
    return QDateTime::currentMSecsSinceEpoch();
}

void ScriptApi::delay(int ms)
{
    if (ms <= 0) return;
    if (ms > 5000) {
        log("警告: delay 超过 5 秒被限制为 5 秒");
        ms = 5000;
    }
    QThread::msleep(ms);
}
