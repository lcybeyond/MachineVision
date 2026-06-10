#ifndef GLOBALVARIABLEMANAGER_H
#define GLOBALVARIABLEMANAGER_H

#include <QObject>
#include <QVariant>
#include <QList>
#include <QtQml/qqmlregistration.h>

class GlobalVariableManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList variables READ variables NOTIFY variablesChanged)
    QML_ELEMENT

public:
    explicit GlobalVariableManager(QObject *parent = nullptr);

    QVariantList variables() const;

    Q_INVOKABLE void addVariable(const QString &name, const QString &type,
                                 const QVariant &value);
    Q_INVOKABLE void removeVariable(const QString &name);
    Q_INVOKABLE QVariantMap getVariable(const QString &name) const;
    Q_INVOKABLE void loadFromFile(const QString &path);
    Q_INVOKABLE void saveToFile(const QString &path) const;

    QVariantMap toScriptValues() const;

signals:
    void variablesChanged();

private:
    struct Var {
        QString name;
        QString type;
        QVariant value;
    };
    QList<Var> m_variables;
};

#endif // GLOBALVARIABLEMANAGER_H
