// FileConfig.cpp - 文件配置管理实现
// 提供文件读写、目录操作和 JSON 格式设置持久化功能。
// 管理应用脚本目录、连接配置目录和全局设置文件。

#include "FileConfig.h"
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>

FileConfig::FileConfig(QObject *parent)
    : QObject(parent)
{
}

// 读取文本文件内容
// 以只读模式打开文件，返回全部文本内容；失败时返回空字符串
QString FileConfig::readFile(const QString &path) const
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();
    return QTextStream(&file).readAll();
}

// 写入文本内容到文件
// 以只写模式打开文件并写入内容，返回操作是否成功
bool FileConfig::writeFile(const QString &path, const QString &content) const
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;
    QTextStream out(&file);
    out << content;
    return true;
}

// 列出指定目录下的所有文件
// 返回按名称排序的文件名列表（不含 . 和 ..）
QStringList FileConfig::listFiles(const QString &dirPath) const
{
    QDir dir(dirPath);
    return dir.entryList(QDir::Files | QDir::NoDotAndDotDot, QDir::Name);
}

// 删除指定路径的文件
// 返回删除操作是否成功
bool FileConfig::deleteFile(const QString &path) const
{
    return QFile::remove(path);
}

// 获取应用基础目录路径
// 基于应用程序所在目录向上三级，即项目根目录
static QString baseDir()
{
    return QDir::cleanPath(QCoreApplication::applicationDirPath() + "/../../..");
}

// 获取脚本目录路径
// 返回 <项目根>/Scripts 目录，目录不存在时自动创建
QString FileConfig::scriptDir() const
{
    QString dir = baseDir() + "/Scripts";
    QDir().mkpath(dir);
    return dir;
}

// 获取设置文件的完整路径
static QString settingJsonPath()
{
    return baseDir() + "/Scripts/Setting.json";
}

// 从 JSON 设置文件中读取指定键的值
// 解析 Setting.json 文件，返回对应键的字符串值
QString FileConfig::loadSetting(const QString &key) const
{
    QFile file(settingJsonPath());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    return doc.object().value(key).toString();
}

// 保存键值对到 JSON 设置文件
// 读取现有设置、合并新值后以格式化 JSON 写回文件
void FileConfig::saveSetting(const QString &key, const QString &value)
{
    QDir().mkpath(baseDir() + "/Scripts");

    QVariantMap map;
    QFile file(settingJsonPath());
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        map = doc.object().toVariantMap();
        file.close();
    }

    map[key] = value;

    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QJsonDocument doc(QJsonObject::fromVariantMap(map));
        file.write(doc.toJson(QJsonDocument::Indented));
    }
}

// 获取连接配置目录路径
// 返回 <项目根>/Connections 目录，目录不存在时自动创建
QString FileConfig::connDir() const
{
    QString dir = baseDir() + "/Connections";
    QDir().mkpath(dir);
    return dir;
}
