#ifndef I2CIF_H
#define I2CIF_H
#include <QObject>

class I2cif : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString variable READ readVar WRITE writeVar(QString) NOTIFY varChanged())

public:
    explicit I2cif(QObject *parent = 0);
    ~I2cif();

    QString readVar();
    void writeVar(QString);

    Q_INVOKABLE void readInitParams();
    Q_INVOKABLE void clearVar();

signals:
    void varChanged();

private:
    QString m_var;
};


#endif // I2CIF_H

