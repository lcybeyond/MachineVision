#ifndef ALGORITHMMANAGER_H
#define ALGORITHMMANAGER_H

#include <QObject>
#include <QList>
#include <QtQml/qqmlregistration.h>
#include "AbstractAlgorithm.h"

// 算法管理器，负责算法的生命周期管理，包括创建、删除和查询。
// 注册为 QML 元素，可在 QML 中直接使用。
class AlgorithmManager : public QObject
{
    Q_OBJECT
    // 当前所有算法对象的列表
    Q_PROPERTY(QVariantList algorithms READ algorithms NOTIFY algorithmsChanged)
    // 当前算法对象的数量
    Q_PROPERTY(int algorithmCount READ algorithmCount NOTIFY algorithmsChanged)
    // 系统支持的所有算法类型名称列表（常量）
    Q_PROPERTY(QStringList algorithmTypes READ algorithmTypes CONSTANT)
    // 注册为 QML 可用元素
    QML_ELEMENT

public:
    // 构造函数
    // @param parent 父对象指针
    explicit AlgorithmManager(QObject *parent = nullptr);
    // 析构函数，释放所有管理的算法对象
    ~AlgorithmManager() override;

    // 获取当前所有算法对象的列表
    QVariantList algorithms() const;
    // 获取当前算法对象的数量
    int algorithmCount() const { return m_algorithms.size(); }
    // 获取系统支持的所有算法类型名称列表
    QStringList algorithmTypes() const;

    // 创建指定名称和类型的算法实例（可在 QML 中调用）
    // @param name 算法名称
    // @param type 算法类型，默认为 "default"
    // @return 创建的算法对象指针
    Q_INVOKABLE QObject* createAlgorithm(const QString &name,
                                         const QString &type = "default");
    // 按名称移除算法（可在 QML 中调用）
    // @param name 要移除的算法名称
    Q_INVOKABLE void removeAlgorithm(const QString &name);
    // 按索引移除算法（可在 QML 中调用）
    // @param index 要移除的算法索引
    Q_INVOKABLE void removeAlgorithmAt(int index);
    // 按名称查找算法（可在 QML 中调用）
    // @param name 算法名称
    // @return 算法对象指针，未找到返回 nullptr
    Q_INVOKABLE QObject* algorithm(const QString &name) const;
    // 按索引获取算法（可在 QML 中调用）
    // @param index 算法索引
    // @return 算法对象指针
    Q_INVOKABLE QObject* algorithmAt(int index) const;

signals:
    // 当算法列表发生变更（新增或删除）时发射
    void algorithmsChanged();

private:
    // 算法对象列表
    QList<AbstractAlgorithm *> m_algorithms;
};

#endif // ALGORITHMMANAGER_H
