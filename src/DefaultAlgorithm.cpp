#include "DefaultAlgorithm.h"

DefaultAlgorithm::DefaultAlgorithm(QObject *parent)
    : AbstractAlgorithm(parent)
{
}

void DefaultAlgorithm::setThreshold(int t)
{
    if (m_threshold != t) {
        m_threshold = t;
        emit thresholdChanged();
    }
}

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
