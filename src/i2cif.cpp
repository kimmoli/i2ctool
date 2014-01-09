#include "i2cif.h"
#include <QSettings>
#include <QCoreApplication>

I2cif::I2cif(QObject *parent) :
    QObject(parent)
{
    m_var = "";
}

void I2cif::readInitParams()
{
    QSettings settings;
    m_var = settings.value("var", "").toString();

    emit varChanged();
}

I2cif::~I2cif()
{
}


QString I2cif::readVar()
{
    return m_var;
}

void I2cif::writeVar(QString s)
{
    m_var = s;

    emit varChanged();
}

void I2cif::clearVar()
{
    m_var = "";

    emit varChanged();
}

