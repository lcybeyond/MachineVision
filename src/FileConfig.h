#ifndef FILECONFIG_H
#define FILECONFIG_H

// FileConfig — 文件配置工具类
// QML 单例，提供跨平台的文件读写、目录浏览、设置存储等文件系统操作接口。
// 封装了 Qt 文件 API，供 QML 前端直接调用，简化脚本与配置文件的存取。

#include <QObject>
#include <QtQml/qqmlregistration.h>
#include <QJSEngine>
#include <QQmlEngine>

class FileConfig : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:

    // 构造函数，初始化文件配置工具对象
    explicit FileConfig(QObject *parent = nullptr);

    // 读取指定路径文件的全部文本内容，失败返回空字符串
    Q_INVOKABLE QString readFile(const QString &path) const;
    // 将文本内容写入指定路径文件，返回是否写入成功
    Q_INVOKABLE bool writeFile(const QString &path, const QString &content) const;
    // 列出指定目录下的所有文件名，返回文件名列表
    Q_INVOKABLE QStringList listFiles(const QString &dirPath) const;
    // 删除指定路径的文件，返回是否删除成功
    Q_INVOKABLE bool deleteFile(const QString &path) const;
    // 返回当前脚本所在的目录路径
    Q_INVOKABLE QString scriptDir() const;
    // 加载指定键名的设置值，从持久化存储中读取
    Q_INVOKABLE QString loadSetting(const QString &key) const;
    // 保存指定键名的设置值到持久化存储中
    Q_INVOKABLE void saveSetting(const QString &key, const QString &value);
    // 返回连接配置文件的目录路径
    Q_INVOKABLE QString connDir() const;
};

#endif // FILECONFIG_H
