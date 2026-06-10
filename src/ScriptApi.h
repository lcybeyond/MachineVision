#ifndef SCRIPTAPI_H
#define SCRIPTAPI_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

class ScriptApi : public QObject
{
    Q_OBJECT

public:
    explicit ScriptApi(QObject *parent = nullptr);

    void setConnectionMgr(QObject *mgr);
    void setAlgorithmManager(QObject *mgr);

public slots:
    // -- 核心算法调用 --
    QVariantMap callProcess(const QString &algoName, const QVariantMap &input);
    QStringList algorithmNames() const;
    QStringList algorithmTypes() const;

    // -- 连接查询 --
    QVariantList readRegs(const QString &connName, int addr, int count);
    void writeReg(const QString &connName, int addr, int value);
    void writeRegs(const QString &connName, int addr, const QVariantList &values);
    bool isConnected(const QString &connName);
    QString connStatus(const QString &connName);
    QStringList connectionNames() const;

    // -- 结果存取 --
    void setResult(const QString &key, const QVariant &value);
    QVariant getResult(const QString &key) const;
    void clearResults();

    // -- 工具 --
    void log(const QString &msg);
    qint64 now() const;
    void delay(int ms);

private:
    QObject* findConnection(const QString &name) const;
    QObject* findAlgorithm(const QString &name) const;

    QObject *m_connMgr{nullptr};
    QObject *m_algoMgr{nullptr};
    QVariantMap m_results;
};

#endif // SCRIPTAPI_H
