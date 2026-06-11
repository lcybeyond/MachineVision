#ifndef ALGORITHMSCRIPTENGINE_H
#define ALGORITHMSCRIPTENGINE_H

#include <QObject>
#include <QVariant>
#include <QJSEngine>
#include <ScriptApi.h>

class GlobalVariableManager;

// 算法脚本引擎，封装 QJSEngine 提供 JavaScript 执行环境。
// 用于运行算法脚本，支持与算法管理器、连接管理器和全局变量管理器交互。
class AlgorithmScriptEngine : public QObject
{
    Q_OBJECT
    // 结果图像的 URL，用于展示检测结果图片
    Q_PROPERTY(QString resultImageUrl READ resultImageUrl NOTIFY resultImageUrlChanged)
    // 检测判定结果文本，例如 "OK" 或 "NG"
    Q_PROPERTY(QString verdict READ verdict NOTIFY verdictChanged)

public:
    // 构造函数
    // @param parent 父对象指针
    explicit AlgorithmScriptEngine(QObject *parent = nullptr);
    // 析构函数，释放 JS 引擎和相关资源
    ~AlgorithmScriptEngine() override;

    // 设置连接管理器，使脚本可以访问设备连接
    void setConnectionMgr(QObject *mgr);
    // 设置算法管理器，使脚本可以访问其他算法
    void setAlgorithmManager(QObject *mgr);
    // 设置全局变量管理器，使脚本可以读写全局变量
    void setGlobalVariableManager(GlobalVariableManager *mgr);
    // 设置日志记录器，用于脚本的日志输出
    void setLogger(QObject *logger);

    // 设置日志输出前缀（可在 QML 中调用）
    Q_INVOKABLE void setLogPrefix(const QString &prefix);

    // 执行 JavaScript 代码并返回结果（可在 QML 中调用）
    // @param code 要执行的 JavaScript 代码
    // @return 执行结果
    Q_INVOKABLE QVariant evaluate(const QString &code);
    // 调用脚本中已定义的函数（可在 QML 中调用）
    // @param funcName 函数名称
    // @param args 函数参数列表
    // @return 函数返回值
    Q_INVOKABLE QVariant callFunction(const QString &funcName,
                                      const QVariantList &args);
    // 检查脚本中是否存在指定函数（可在 QML 中调用）
    // @param funcName 函数名称
    // @return 存在返回 true，否则返回 false
    Q_INVOKABLE bool hasFunction(const QString &funcName) const;
    // 停止当前正在执行的脚本（可在 QML 中调用）
    Q_INVOKABLE void stop();

    // 获取结果图像 URL
    QString resultImageUrl() const;
    // 设置结果图像 URL（可在 QML 中调用）
    Q_INVOKABLE void setResultImageUrl(const QString &url);
    // 获取检测判定结果
    QString verdict() const;
    // 设置检测判定结果（可在 QML 中调用）
    Q_INVOKABLE void setVerdict(const QString &v);

signals:
    // 当脚本执行出错时发射，携带错误信息
    void scriptError(const QString &message);
    // 当脚本产生输出时发射，携带输出内容
    void scriptOutput(const QString &message);
    // 当结果图像 URL 变更时发射
    void resultImageUrlChanged();
    // 当检测判定结果变更时发射
    void verdictChanged();

private:
    // 初始化 JS 引擎，注册 ScriptApi 和全局变量
    void setupEngine();
    // JavaScript 引擎实例
    QJSEngine *m_engine{nullptr};
    // 脚本 API 对象，暴露给 JS 的 C++ 接口
    ScriptApi *m_api{nullptr};
    // 全局变量管理器
    GlobalVariableManager *m_globalVarMgr{nullptr};
    // 已注入到 JS 环境中的全局变量名称列表
    QStringList m_injectedVarNames;
    // 结果图像 URL
    QString m_resultImageUrl;
    // 检测判定结果
    QString m_verdict;
};

#endif // ALGORITHMSCRIPTENGINE_H
