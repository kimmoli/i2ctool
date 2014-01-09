#ifndef I2CIF_H
#define I2CIF_H
#include <QObject>

class I2cif : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString i2cProbingStatus READ i2cProbingStatus  NOTIFY i2cProbingChanged)
    Q_PROPERTY(QString i2cReadResult READ i2cReadResult  NOTIFY i2cReadResultChanged)

public:
    explicit I2cif(QObject *parent = 0);
    ~I2cif();

    QString i2cProbingStatus();
    QString i2cReadResult();

    Q_INVOKABLE void i2cProbe(QString devName, unsigned char address);
    Q_INVOKABLE void i2cWrite(QString devName, unsigned char address, QString data);
    Q_INVOKABLE void i2cRead(QString devName, unsigned char address, int count);
    Q_INVOKABLE void tohVddSet(QString onOff);

signals:
    void i2cProbingChanged();
    void i2cError();
    void i2cWriteOk();
    void i2cReadResultChanged();

private:
    QString m_probingResult;
    QString m_readResult;

};


#endif // I2CIF_H

