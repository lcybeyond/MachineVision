// 文件: AbstractConnection.cpp
// 功能: 实现 AbstractConnection 类——连接基类，所有具体连接（Modbus、串口、相机等）均继承自此抽象类

#include "AbstractConnection.h"

// 构造函数：初始化抽象连接对象
AbstractConnection::AbstractConnection(QObject *parent)
    : QObject(parent)
{
}

// 设置连接名称，若名称变化则触发 nameChanged 信号
void AbstractConnection::setName(const QString &name)
{
    if (m_name != name) {
        m_name = name;
        emit nameChanged();
    }
}
