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

QVariantMap GlobalVariableManager::toScriptValues() const
{
    QVariantMap map;
    for (const auto &v : m_variables)
        map[v.name] = v.value;
    return map;
}
