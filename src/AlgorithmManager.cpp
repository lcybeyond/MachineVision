#include "AlgorithmManager.h"
#include "DefaultAlgorithm.h"

AlgorithmManager::AlgorithmManager(QObject *parent)
    : QObject(parent)
{
}

AlgorithmManager::~AlgorithmManager()
{
    qDeleteAll(m_algorithms);
}

QVariantList AlgorithmManager::algorithms() const
{
    QVariantList list;
    for (auto *a : m_algorithms)
        list.append(QVariant::fromValue(static_cast<QObject *>(a)));
    return list;
}

QStringList AlgorithmManager::algorithmTypes() const
{
    return {"default"};
}

QObject* AlgorithmManager::createAlgorithm(const QString &name,
                                           const QString &type)
{
    AbstractAlgorithm *algo = nullptr;

    if (type == "default")
        algo = new DefaultAlgorithm(this);
    // else if (type == "edgeDetect")
    //     algo = new EdgeDetectAlgorithm(this);
    else
        algo = new DefaultAlgorithm(this);

    algo->setName(name);
    m_algorithms.append(algo);
    emit algorithmsChanged();
    return algo;
}

void AlgorithmManager::removeAlgorithm(const QString &name)
{
    for (int i = 0; i < m_algorithms.size(); ++i) {
        if (m_algorithms[i]->name() == name) {
            delete m_algorithms.takeAt(i);
            emit algorithmsChanged();
            return;
        }
    }
}

void AlgorithmManager::removeAlgorithmAt(int index)
{
    if (index >= 0 && index < m_algorithms.size()) {
        delete m_algorithms.takeAt(index);
        emit algorithmsChanged();
    }
}

QObject* AlgorithmManager::algorithm(const QString &name) const
{
    for (auto *a : m_algorithms) {
        if (a->name() == name)
            return a;
    }
    return nullptr;
}

QObject* AlgorithmManager::algorithmAt(int index) const
{
    if (index >= 0 && index < m_algorithms.size())
        return m_algorithms[index];
    return nullptr;
}
