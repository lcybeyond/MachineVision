// GlobalVariableManager.cpp - 全局变量管理器实现
// 提供全局变量的增删改查功能，支持从 JSON 文件加载和保存变量。
// 变量按名称索引，支持 number、boolean 和 string 三种类型。

#include "GlobalVariableManager.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>

GlobalVariableManager::GlobalVariableManager(QObject *parent)
    : QObject(parent)
{
}

// 获取所有变量的列表
// 将内部变量列表转换为 QVariantList，每个元素包含 name、type、value 字段
QVariantList GlobalVariableManager::variables() const
{
    QVariantList list;
    for (const auto &v : m_variables) {
        QVariantMap item;
        item["name"] = v.name;
        item["type"] = v.type;
        item["value"] = v.value;
        list.append(item);
    }
    return list;
}

// 添加或更新变量
// 根据指定类型转换值：number 转为 double，boolean 转为 bool，其他转 string
// 若变量已存在则更新，否则追加新变量
void GlobalVariableManager::addVariable(const QString &name, const QString &type,
                                        const QVariant &value)
{
    QVariant typed;
    if (type == "number")
        typed = QVariant(value.toDouble());
    else if (type == "boolean")
        typed = QVariant(value.toBool());
    else
        typed = QVariant(value.toString());

    for (auto &v : m_variables) {
        if (v.name == name) {
            v.type = type;
            v.value = typed;
            emit variablesChanged();
            return;
        }
    }
    m_variables.append({name, type, typed});
    emit variablesChanged();
}

// 按名称删除变量
// 遍历查找并移除匹配的变量，找到后发射变更信号
void GlobalVariableManager::removeVariable(const QString &name)
{
    for (int i = 0; i < m_variables.size(); ++i) {
        if (m_variables[i].name == name) {
            m_variables.removeAt(i);
            emit variablesChanged();
            return;
        }
    }
}

// 按名称获取单个变量
// 返回包含 name、type、value 的 QVariantMap，未找到时返回空 map
QVariantMap GlobalVariableManager::getVariable(const QString &name) const
{
    for (const auto &v : m_variables) {
        if (v.name == name) {
            QVariantMap item;
            item["name"] = v.name;
            item["type"] = v.type;
            item["value"] = v.value;
            return item;
        }
    }
    return {};
}

// 从 JSON 文件加载变量列表
// 解析文件中 "variables" 数组，清空现有变量后全部加载
void GlobalVariableManager::loadFromFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    QJsonArray arr = doc.object().value("variables").toArray();

    m_variables.clear();
    for (const auto &val : arr) {
        QJsonObject obj = val.toObject();
        Var v;
        v.name = obj["name"].toString();
        v.type = obj["type"].toString();
        v.value = obj["value"].toVariant();
        m_variables.append(v);
    }
    emit variablesChanged();
}

// 将变量列表保存到 JSON 文件
// 将内部变量列表序列化为 JSON 数组，以格式化 JSON 写入文件
void GlobalVariableManager::saveToFile(const QString &path) const
{
    QJsonArray arr;
    for (const auto &v : m_variables) {
        QJsonObject obj;
        obj["name"] = v.name;
        obj["type"] = v.type;
        obj["value"] = QJsonValue::fromVariant(v.value);
        arr.append(obj);
    }

    QJsonObject root;
    root["variables"] = arr;

    QDir().mkpath(QFileInfo(path).absolutePath());
    QFile file(path);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        file.write(QJsonDocument(root).toJson(QJsonDocument::Indented));
    }
}

// 将变量转换为脚本可用的键值对映射
// 以变量名为键、变量值为值，生成 QVariantMap 供脚本引擎使用
QVariantMap GlobalVariableManager::toScriptValues() const
{
    QVariantMap map;
    for (const auto &v : m_variables)
        map[v.name] = v.value;
    return map;
}
