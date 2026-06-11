// 文件: AlgorithmManager.cpp
// 功能: 实现 AlgorithmManager 类——算法管理器，负责算法的创建、删除、查询等生命周期管理

#include "AlgorithmManager.h"
#include "DefaultAlgorithm.h"

// 构造函数：初始化算法管理器
AlgorithmManager::AlgorithmManager(QObject *parent)
    : QObject(parent)
{
}

// 析构函数：释放所有算法对象
AlgorithmManager::~AlgorithmManager()
{
    qDeleteAll(m_algorithms);
}

// 获取所有算法的列表，以 QVariantList 形式返回，供 QML 侧使用
QVariantList AlgorithmManager::algorithms() const
{
    QVariantList list;
    for (auto *a : m_algorithms)
        list.append(QVariant::fromValue(static_cast<QObject *>(a)));
    return list;
}

// 获取当前支持的算法类型列表
QStringList AlgorithmManager::algorithmTypes() const
{
    return {"default"};
}

// 根据名称和类型创建一个算法实例，并加入管理列表
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

// 根据名称删除指定的算法
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

// 根据索引删除指定位置的算法
void AlgorithmManager::removeAlgorithmAt(int index)
{
    if (index >= 0 && index < m_algorithms.size()) {
        delete m_algorithms.takeAt(index);
        emit algorithmsChanged();
    }
}

// 根据名称查找并返回算法对象
QObject* AlgorithmManager::algorithm(const QString &name) const
{
    for (auto *a : m_algorithms) {
        if (a->name() == name)
            return a;
    }
    return nullptr;
}

// 根据索引查找并返回算法对象
QObject* AlgorithmManager::algorithmAt(int index) const
{
    if (index >= 0 && index < m_algorithms.size())
        return m_algorithms[index];
    return nullptr;
}
