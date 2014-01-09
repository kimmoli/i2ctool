#ifndef CONV_H
#define CONV_H

#include <QObject>
#include <QString>
#include <QColor>

class Conv : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE QString toHex(QColor col);
    Q_INVOKABLE QString toHex(int a, int l);
    Q_INVOKABLE int toInt(QString in);
};



#endif // CONV_H
