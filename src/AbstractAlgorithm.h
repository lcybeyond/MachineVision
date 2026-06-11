#ifndef ABSTRACTALGORITHM_H
#define ABSTRACTALGORITHM_H

#include <QObject>
#include <QVariantMap>

// 算法抽象基类，定义所有算法的通用接口。
// 子类必须实现 algorithmType() 和 process() 两个纯虚函数。
class AbstractAlgorithm : public QObject
{
    Q_OBJECT
    // 算法名称，可通过 QML 绑定读写
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    // 算法类型标识（常量），由子类实现，创建后不可更改
    Q_PROPERTY(QString algorithmType READ algorithmType CONSTANT)

public:
    // 构造函数
    // @param parent 父对象指针
    explicit AbstractAlgorithm(QObject *parent = nullptr);

    // 获取算法名称
    QString name() const { return m_name; }
    // 设置算法名称，修改后发射 nameChanged 信号
    void setName(const QString &name);

    // 纯虚函数，返回算法类型标识字符串
    virtual QString algorithmType() const = 0;
    // 纯虚函数，处理输入数据并返回处理结果
    // @param input 输入数据的键值对
    // @return 处理结果的键值对
    virtual QVariantMap process(const QVariantMap &input) = 0;

signals:
    // 当算法名称变更时发射
    void nameChanged();

protected:
    // 算法名称
    QString m_name;
};

#endif // ABSTRACTALGORITHM_H
