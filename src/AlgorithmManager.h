#ifndef ALGORITHMMANAGER_H
#define ALGORITHMMANAGER_H

#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include "AbstractAlgorithm.h"

class AlgorithmManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList algorithms READ algorithms NOTIFY algorithmsChanged)
    Q_PROPERTY(int algorithmCount READ algorithmCount NOTIFY algorithmsChanged)
    Q_PROPERTY(QStringList algorithmTypes READ algorithmTypes CONSTANT)
    QML_ELEMENT

public:
    explicit AlgorithmManager(QObject *parent = nullptr);
    ~AlgorithmManager() override;

    QVariantList algorithms() const;
    int algorithmCount() const { return m_algorithms.size(); }
    QStringList algorithmTypes() const;

    Q_INVOKABLE QObject* createAlgorithm(const QString &name,
                                         const QString &type = "default");
    Q_INVOKABLE void removeAlgorithm(const QString &name);
    Q_INVOKABLE void removeAlgorithmAt(int index);
    Q_INVOKABLE QObject* algorithm(const QString &name) const;
    Q_INVOKABLE QObject* algorithmAt(int index) const;

signals:
    void algorithmsChanged();

private:
    QList<AbstractAlgorithm *> m_algorithms;
};

#endif // ALGORITHMMANAGER_H
