// 文件: AbstractAlgorithm.cpp
// 功能: 实现 AbstractAlgorithm 类——算法基类，所有具体算法实现均继承自此抽象类

#include "AbstractAlgorithm.h"

// 构造函数：初始化抽象算法对象
AbstractAlgorithm::AbstractAlgorithm(QObject *parent)
    : QObject(parent)
{
}

// 设置算法名称，若名称变化则触发 nameChanged 信号
void AbstractAlgorithm::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}
