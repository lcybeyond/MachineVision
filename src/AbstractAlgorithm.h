#ifndef ABSTRACTALGORITHM_H
#define ABSTRACTALGORITHM_H

#include <QObject>
#include <QVariantMap>

class AbstractAlgorithm : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString algorithmType READ algorithmType CONSTANT)

public:
    explicit AbstractAlgorithm(QObject *parent = nullptr);

    QString name() const { return m_name; }
    void setName(const QString &name);

    virtual QString algorithmType() const = 0;
    virtual QVariantMap process(const QVariantMap &input) = 0;

signals:
    void nameChanged();

protected:
    QString m_name;
};

#endif // ABSTRACTALGORITHM_H
