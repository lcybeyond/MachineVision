// ScriptApi.h
// 脚本 API 桥接类，为算法脚本引擎提供调用 C++ 功能的标准接口。
// 封装了算法调用、连接管理、结果存取、相机控制和工具方法等核心能力，
// 使得 JS/脚本层可以通过此类安全地访问 CPP 层的业务逻辑。

#ifndef SCRIPTAPI_H
#define SCRIPTAPI_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <Logger.h>

class AlgorithmScriptEngine;

class ScriptApi : public QObject
{
    Q_OBJECT

public:
    // 构造函数
    explicit ScriptApi(QObject *parent = nullptr);

    // 设置连接管理器，用于读写寄存器和查询连接状态
    void setConnectionMgr(QObject *mgr);
    // 设置算法管理器，用于调用已注册的算法处理函数
    void setAlgorithmManager(QObject *mgr);
    // 设置日志记录器，用于脚本中输出日志
    void setLogger(Logger *logger);
    // 设置日志前缀，用于区分不同脚本的输出
    void setLogPrefix(const QString &prefix);
    // 设置所属的算法脚本引擎，用于结果回调和状态同步
    void setEngine(AlgorithmScriptEngine *engine);

public slots:
    // -- 核心算法调用 --
    // 调用指定名称的算法处理函数，传入 input 参数，返回处理结果
    QVariantMap callProcess(const QString &algoName, const QVariantMap &input);
    // 获取所有已注册算法的名称列表
    QStringList algorithmNames() const;
    // 获取所有已注册算法的类型列表
    QStringList algorithmTypes() const;

    // -- 连接查询 --
    // 从指定连接的从站读取连续多个寄存器的值
    QVariantList readRegs(const QString &connName, int addr, int count);
    // 向指定连接的从站写入单个寄存器的值
    void writeReg(const QString &connName, int addr, int value);
    // 向指定连接的从站批量写入多个寄存器的值
    void writeRegs(const QString &connName, int addr, const QVariantList &values);
    // 查询指定连接是否已建立连接
    bool isConnected(const QString &connName);
    // 获取指定连接的状态文本描述
    QString connStatus(const QString &connName);
    // 获取所有已注册的连接名称列表
    QStringList connectionNames() const;

    // -- 结果存取 --
    // 保存一个键值对结果，供脚本后续使用
    void setResult(const QString &key, const QVariant &value);
    // 根据键名获取之前保存的结果
    QVariant getResult(const QString &key) const;
    // 清除所有已保存的结果
    void clearResults();

    // -- 相机 / 图像 --
    // 触发指定相机拍照并返回图像数据
    QVariantMap capture(const QString &cameraName);
    // 将处理后的像素数据显示到界面
    void showResult(const QVariantMap &pixelData);
    // 设置判定结果（如 OK/NG）
    void setVerdict(const QString &v);

    // -- 工具 --
    // 在日志中输出一条消息
    void log(const QString &msg);
    // 获取当前时间戳（毫秒）
    qint64 now() const;
    // 阻塞延迟指定毫秒数
    void delay(int ms);

private:
    // 根据名称查找对应的连接对象
    QObject* findConnection(const QString &name) const;
    // 根据名称查找对应的算法对象
    QObject* findAlgorithm(const QString &name) const;

    // 连接管理器指针
    QObject *m_connMgr{nullptr};
    // 算法管理器指针
    QObject *m_algoMgr{nullptr};
    // 日志记录器指针
    Logger *m_logger{nullptr};
    // 所属的算法脚本引擎指针
    AlgorithmScriptEngine *m_engine{nullptr};
    // 日志前缀字符串
    QString m_logPrefix;
    // 脚本内存储的键值对结果集
    QVariantMap m_results;
};

#endif // SCRIPTAPI_H
