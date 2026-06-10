#ifndef DEFAULTALGORITHM_H
#define DEFAULTALGORITHM_H

#include "AbstractAlgorithm.h"

class DefaultAlgorithm : public AbstractAlgorithm
{
    Q_OBJECT
    Q_PROPERTY(int threshold READ threshold WRITE setThreshold NOTIFY thresholdChanged)

public:
    explicit DefaultAlgorithm(QObject *parent = nullptr);

    QString algorithmType() const override { return QStringLiteral("default"); }

    int threshold() const { return m_threshold; }
    void setThreshold(int t);

    QVariantMap process(const QVariantMap &input) override;

signals:
    void thresholdChanged();

private:
    int m_threshold{100};
};

#endif // DEFAULTALGORITHM_H
