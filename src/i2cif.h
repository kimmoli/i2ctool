#ifndef I2CIF_H
#define I2CIF_H
#include <QObject>
#include <QStringList>

class I2cif : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList i2cProbingStatus READ i2cProbingStatus  NOTIFY i2cProbingChanged)
    Q_PROPERTY(QString i2cReadResult READ i2cReadResult  NOTIFY i2cReadResultChanged)
    Q_PROPERTY(bool tohVddStatus READ tohVddGet NOTIFY tohVddStatusChanged)

public:
    explicit I2cif(QObject *parent = 0);
    ~I2cif();

    QStringList i2cProbingStatus();
    QString i2cReadResult();

    Q_INVOKABLE void i2cProbe(QString devName);
    Q_INVOKABLE void i2cWrite(QString devName, unsigned char address, QString data);
    Q_INVOKABLE void i2cRead(QString devName, unsigned char address, int count);
    Q_INVOKABLE void tohVddSet(QString onOff);
    bool tohVddGet();
    Q_INVOKABLE void requestTohVddState();
    Q_INVOKABLE void unbindTohCore();

    Q_INVOKABLE void setAsDefault(QString index, QString value);
    Q_INVOKABLE QString getDefault(QString index);

    Q_INVOKABLE void openUsersGuide();

    QString firstTimeDefault(QString index);

signals:
    void i2cProbingChanged();
    void i2cError();
    void i2cWriteOk();
    void i2cReadResultChanged();
    void tohVddStatusChanged();

private:
    QStringList m_probingResult;
    QString m_readResult;

};


#endif // I2CIF_H

