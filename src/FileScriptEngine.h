#ifndef FILESCRIPTENGINE_H
#define FILESCRIPTENGINE_H

#include <QObject>
#include <QtQml/qqmlregistration.h>

class FileScriptEngine : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit FileScriptEngine(QObject *parent = nullptr);

    Q_INVOKABLE QString readFile(const QString &path) const;
    Q_INVOKABLE bool writeFile(const QString &path, const QString &content) const;
    Q_INVOKABLE QStringList listFiles(const QString &dirPath) const;
    Q_INVOKABLE bool deleteFile(const QString &path) const;
    Q_INVOKABLE QString scriptDir() const;
    Q_INVOKABLE QString loadSetting(const QString &key) const;
    Q_INVOKABLE void saveSetting(const QString &key, const QString &value);
    Q_INVOKABLE QString connDir() const;
};

#endif // FILESCRIPTENGINE_H
