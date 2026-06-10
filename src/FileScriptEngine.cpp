#include "FileScriptEngine.h"
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QCoreApplication>

FileScriptEngine::FileScriptEngine(QObject *parent)
    : QObject(parent)
{
}

QString FileScriptEngine::readFile(const QString &path) const
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();
    return QTextStream(&file).readAll();
}

bool FileScriptEngine::writeFile(const QString &path, const QString &content) const
{
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        return false;
    QTextStream out(&file);
    out << content;
    return true;
}

QStringList FileScriptEngine::listFiles(const QString &dirPath) const
{
    QDir dir(dirPath);
    return dir.entryList(QDir::Files | QDir::NoDotAndDotDot, QDir::Name);
}

bool FileScriptEngine::deleteFile(const QString &path) const
{
    return QFile::remove(path);
}

static QString baseDir()
{
    return QDir::cleanPath(QCoreApplication::applicationDirPath() + "/../../..");
}

QString FileScriptEngine::scriptDir() const
{
    QString dir = baseDir() + "/Scripts";
    QDir().mkpath(dir);
    return dir;
}

static QString settingJsonPath()
{
    return baseDir() + "/Scripts/Setting.json";
}

QString FileScriptEngine::loadSetting(const QString &key) const
{
    QFile file(settingJsonPath());
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    return doc.object().value(key).toString();
}

void FileScriptEngine::saveSetting(const QString &key, const QString &value)
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

QString FileScriptEngine::connDir() const
{
    QString dir = baseDir() + "/Connections";
    QDir().mkpath(dir);
    return dir;
}
