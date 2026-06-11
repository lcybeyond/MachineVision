#ifndef DEFAULTALGORITHM_H
#define DEFAULTALGORITHM_H

// DefaultAlgorithm — 默认图像处理算法类
// 继承自 AbstractAlgorithm，提供基础的图像处理功能。
// 通过阈（yu）值参数控制处理强度，处理结果以 QVariantMap 形式返回。

#include "AbstractAlgorithm.h"

class DefaultAlgorithm : public AbstractAlgorithm
{
    Q_OBJECT
    // threshold: 算法处理的阈值参数，可读写，修改时发出通知
    Q_PROPERTY(int threshold READ threshold WRITE setThreshold NOTIFY thresholdChanged)

public:
    // 构造函数，初始化默认算法对象，阈（yu）值默认为 100
    explicit DefaultAlgorithm(QObject *parent = nullptr);

    // 返回算法类型标识，固定为 "default"
    QString algorithmType() const override { return QStringLiteral("default"); }

    // 返回当前阈值
    int threshold() const { return m_threshold; }
    // 设置新的阈值，若值发生变化则发出 thresholdChanged 信号
    void setThreshold(int t);

    // 对输入数据进行处理，返回处理后的结果数据
    QVariantMap process(const QVariantMap &input) override;

signals:
    // 当阈值发生变化时发出此信号
    void thresholdChanged();

private:
    int m_threshold{100};
};

#endif // DEFAULTALGORITHM_H
