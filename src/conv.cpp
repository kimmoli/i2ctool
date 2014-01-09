
#include <QString>
#include <QColor>
#include "conv.h"
#include <QString>

QString Conv::toHex(QColor col)
{
    return col.name();
}

QString Conv::toHex(int intIn, int l)
{
    return QString("%1").arg(intIn, l, 16, QChar('0')).toUpper();
}

int Conv::toInt(QString in)
{
    bool parseOk;
    return in.toInt(&parseOk, 16);
}
