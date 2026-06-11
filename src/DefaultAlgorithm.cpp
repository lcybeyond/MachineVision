// DefaultAlgorithm.cpp - 默认算法实现
// 提供基础的图像处理算法功能，包括阈值设置和输入数据处理。
// 作为 AbstractAlgorithm 的默认实现，用于简单的数值统计计算。

#include "DefaultAlgorithm.h"

DefaultAlgorithm::DefaultAlgorithm(QObject *parent)
    : AbstractAlgorithm(parent)
{
}

// 设置算法阈值
// 当新值与当前值不同时更新，并发射阈值变更信号
void DefaultAlgorithm::setThreshold(int t)
{
    if (m_threshold != t) {
        m_threshold = t;
        emit thresholdChanged();
    }
}

// 处理输入数据
// 对输入的数值列表进行求和、求平均值等基本统计运算，
// 返回包含处理结果的 QVariantMap
QVariantMap DefaultAlgorithm::process(const QVariantMap &input)
{
    QVariantMap result;
    result["ok"] = true;
    result["algorithm"] = name();
    result["type"] = algorithmType();
    result["threshold"] = m_threshold;
    result["inputKeys"] = input.keys();

    // 提取输入参数
    if (input.contains("values")) {
        QVariantList vals = input["values"].toList();
        double sum = 0;
        for (const auto &v : vals)
            sum += v.toDouble();
        result["sum"] = sum;
        result["avg"] = vals.isEmpty() ? 0 : sum / vals.size();
        result["count"] = vals.size();
    }

    return result;
}
