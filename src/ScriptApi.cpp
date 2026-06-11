// ScriptApi.cpp —— 脚本 API 实现层
// 为 Lua 脚本提供与系统交互的接口，包括算法调用、连接读写、相机采集、结果存取和日志记录等功能
#include "ScriptApi.h"
#include "Logger.h"
#include "AlgorithmScriptEngine.h"
#include <QMetaObject>
#include <QDebug>
#include <QThread>
#include <QDateTime>
#include <QImage>
#include <QDir>

ScriptApi::ScriptApi(QObject *parent)
    : QObject(parent)
{
    // 构造函数：初始化 QObject 基类
}

void ScriptApi::setConnectionMgr(QObject *mgr)
{
    // 设置连接管理器，用于后续查找和管理各种连接（Modbus、串口、相机等）
    m_connMgr = mgr;
}

void ScriptApi::setAlgorithmManager(QObject *mgr)
{
    // 设置算法管理器，用于后续查找和管理各种图像处理算法
    m_algoMgr = mgr;
}

void ScriptApi::setLogger(Logger *logger)
{
    // 设置日志记录器，用于将脚本日志输出到系统日志
    m_logger = logger;
}

void ScriptApi::setLogPrefix(const QString &prefix)
{
    // 设置日志前缀，用于区分不同脚本引擎的日志输出
    m_logPrefix = prefix;
}

void ScriptApi::setEngine(AlgorithmScriptEngine *engine)
{
    // 设置关联的脚本引擎，用于结果图像显示和判据设置
    m_engine = engine;
}

// ========== 内部辅助 ==========

QObject* ScriptApi::findConnection(const QString &name) const
{
    // 根据名称通过连接管理器查找对应的连接对象
    // 使用 QMetaObject::invokeMethod 跨线程调用 connection() 方法
    if (!m_connMgr) return nullptr;

    QObject *conn = nullptr;
    QMetaObject::invokeMethod(m_connMgr, "connection",
        Q_RETURN_ARG(QObject*, conn),
        Q_ARG(QString, name));
    return conn;
}

QObject* ScriptApi::findAlgorithm(const QString &name) const
{
    // 根据名称通过算法管理器查找对应的算法对象
    // 使用 QMetaObject::invokeMethod 跨线程调用 algorithm() 方法
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
    // 调用指定算法的 process 方法，传入输入参数并返回处理结果
    // 如果算法不存在或调用失败，返回包含错误信息的 QVariantMap
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
    // 获取所有已注册算法的名称列表
    // 通过算法管理器获取所有算法对象，然后逐一查询其名称
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
    // 获取所有已注册算法的类型列表
    if (!m_algoMgr) return {};

    QVariant ret;
    QMetaObject::invokeMethod(m_algoMgr, "algorithmTypes",
        Q_RETURN_ARG(QVariant, ret));
    return ret.toStringList();
}

// ========== 连接查询 ==========

QVariantList ScriptApi::readRegs(const QString &connName, int addr, int count)
{
    // 从指定连接的起始地址 addr 处读取 count 个寄存器的值
    // 返回寄存器值列表，连接不存在时返回空列表
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
    // 向指定连接的单个寄存器写入值，内部调用 writeRegs 实现
    writeRegs(connName, addr, {value});
}

void ScriptApi::writeRegs(const QString &connName, int addr,
                           const QVariantList &values)
{
    // 从指定连接的起始地址 addr 处批量写入多个寄存器的值
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
    // 检查指定连接是否处于已连接状态
    auto *conn = findConnection(connName);
    if (!conn) return false;

    QVariant ret;
    QMetaObject::invokeMethod(conn, "connected",
        Q_RETURN_ARG(QVariant, ret));
    return ret.toBool();
}

QString ScriptApi::connStatus(const QString &connName)
{
    // 获取指定连接的状态文本描述
    auto *conn = findConnection(connName);
    if (!conn) return "不存在";

    QVariant ret;
    QMetaObject::invokeMethod(conn, "statusText",
        Q_RETURN_ARG(QVariant, ret));
    return ret.toString();
}

QStringList ScriptApi::connectionNames() const
{
    // 获取所有已注册连接的名称列表
    // 通过连接管理器获取所有连接对象，然后逐一查询其名称
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
    // 以键值对的形式存储脚本执行结果，供后续脚本步骤使用
    m_results[key] = value;
}

QVariant ScriptApi::getResult(const QString &key) const
{
    // 根据键名获取之前存储的脚本执行结果
    return m_results.value(key);
}

void ScriptApi::clearResults()
{
    // 清空所有已存储的结果数据
    m_results.clear();
}

// ========== 相机 / 图像 ==========

QVariantMap ScriptApi::capture(const QString &cameraName)
{
    // 从指定相机采集图像，返回包含宽度、高度和像素数据的 QVariantMap
    // 图像格式转换为 RGBA8888，像素数据以 QVariantList 形式返回
    auto *conn = findConnection(cameraName);
    if (!conn) {
        log("错误: 相机 '" + cameraName + "' 不存在");
        return {};
    }

    if (conn->property("connectionType").toString() != "camera") {
        log("错误: '" + cameraName + "' 不是相机连接");
        return {};
    }

    QVariant imgVar;
    QMetaObject::invokeMethod(conn, "capture",
        Q_RETURN_ARG(QVariant, imgVar));
    QImage img = imgVar.value<QImage>();
    if (img.isNull()) {
        log("错误: 从 '" + cameraName + "' 采集图像失败");
        return {};
    }

    img = img.convertToFormat(QImage::Format_RGBA8888);
    int w = img.width();
    int h = img.height();
    const uchar *bits = img.constBits();
    int byteCount = w * h * 4;

    QVariantList dataList;
    dataList.reserve(byteCount);
    for (int i = 0; i < byteCount; ++i)
        dataList.append(static_cast<int>(bits[i]));

    QVariantMap result;
    result["width"] = w;
    result["height"] = h;
    result["data"] = dataList;

    if (m_engine)
        m_engine->setResultImageUrl(conn->property("imagePath").toString());

    return result;
}

void ScriptApi::showResult(const QVariantMap &pixelData)
{
    // 将像素数据渲染为 PNG 图像并显示在结果视图中
    // pixelData 应包含 width、height 和 data（RGBA8888 像素数组）
    if (!m_engine) {
        log("错误: ScriptApi 未绑定引擎");
        return;
    }

    int w = pixelData.value("width", 0).toInt();
    int h = pixelData.value("height", 0).toInt();
    QVariantList dataList = pixelData.value("data").toList();

    if (w <= 0 || h <= 0 || dataList.size() != w * h * 4) {
        log("错误: showResult 像素数据尺寸不匹配");
        return;
    }

    QImage img(w, h, QImage::Format_RGBA8888);
    uchar *bits = img.bits();
    for (int i = 0; i < dataList.size(); ++i)
        bits[i] = static_cast<uchar>(dataList[i].toInt());

    QString path = QDir::tempPath() + "/result_" +
                   QString::number(QDateTime::currentMSecsSinceEpoch()) + ".png";
    img.save(path, "PNG");

    m_engine->setResultImageUrl(path);
}

void ScriptApi::setVerdict(const QString &v)
{
    // 设置当前脚本执行的判据结果（如 OK / NG）
    if (!m_engine) {
        log("错误: ScriptApi 未绑定引擎");
        return;
    }
    m_engine->setVerdict(v);
}

// ========== 工具 ==========

void ScriptApi::log(const QString &msg)
{
    // 输出日志消息到控制台和系统日志
    // 如果有日志前缀，会自动添加到消息前面
    qDebug().noquote() << "[Script]" << msg;
    if (m_logger) {
        QString line = m_logPrefix.isEmpty() ? msg : (m_logPrefix + ": " + msg);
        m_logger->append(line);
    }
}

qint64 ScriptApi::now() const
{
    // 获取当前时间的毫秒级时间戳
    return QDateTime::currentMSecsSinceEpoch();
}

void ScriptApi::delay(int ms)
{
    // 阻塞当前线程指定毫秒数，用于脚本中的延时等待
    // 最大延迟限制为 5 秒，防止脚本长时间阻塞
    if (ms <= 0) return;
    if (ms > 5000) {
        log("警告: delay 超过 5 秒被限制为 5 秒");
        ms = 5000;
    }
    QThread::msleep(ms);
}
