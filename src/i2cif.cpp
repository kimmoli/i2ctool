#include "i2cif.h"
#include <linux/i2c-dev.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <QCoreApplication>
#include "conv.h"

I2cif::I2cif(QObject *parent) :
    QObject(parent)
{
    m_probingResult = "pending";
    m_readResult = "Nothing yet";
    emit tohVddStatusChanged();
}

I2cif::~I2cif()
{
}


QString I2cif::i2cProbingStatus()
{
    return m_probingResult;
}

QString I2cif::i2cReadResult()
{
    return m_readResult;
}

/*
 * Function to set TOH VDD On and Off
 *
 *
 */

void I2cif::tohVddSet(QString onOff)
{
    int fd;

    fd = open("/sys/devices/platform/reg-userspace-consumer.0/state", O_WRONLY);

    if (!(fd < 0))
    {
        if (write (fd, QString::localeAwareCompare( onOff, "on") ? "0" : "1", 1) != 1)
            fprintf(stderr, "Vdd set failed\n");
        else
            fprintf(stderr, "Vdd set OK\n");

        close(fd);
    }
    else
        fprintf(stderr, "Vdd failed to open. Did you start i2ctool as root?\n");

    emit tohVddStatusChanged();
}

void I2cif::requestTohVddState()
{
    emit tohVddStatusChanged();
}

bool I2cif::tohVddGet()
{
    int fd;
    char buf[1] = { 0 };

    fd = open("/sys/devices/platform/reg-userspace-consumer.0/state", O_RDONLY);

    if (!(fd < 0))
    {
        read(fd, buf ,1);
        close(fd);
    }

    return (buf[0] == 'e'); // returns "enabled" or "disabled"
}



/*
 * I2C Write Function
 *
 *
 */

void I2cif::i2cWrite(QString devName, unsigned char address, QString data)
{
    int file;
    char buf[200];
    bool parseOk;

    QByteArray tmpBa = devName.toUtf8();
    const char* devNameChar = tmpBa.constData();

    fprintf(stderr, "writing to address %02x: ", address);

    /* parse QString data to buf */
    QStringList bytes = data.split(" ");
    int i;
    for (i=0 ; i<bytes.length(); i++)
    {
        QString tmp = bytes.value(i);
        buf[i] = tmp.toInt(&parseOk, 16);
        if (!parseOk)
        {
            fprintf(stderr, "parsing error %d\n", i);
            emit i2cError();
            return;
        }
        fprintf(stderr, "%02x ", buf[i]);
    }
    fprintf(stderr, "\n");


    if ((file = open (devNameChar, O_RDWR)) < 0)
    {
        fprintf(stderr,"open error\n");
        emit i2cError();
        return;
    }

    if (ioctl(file, I2C_SLAVE, address) < 0)
    {
        close(file);
        fprintf(stderr,"ioctl error\n");
        emit i2cError();
        return;
    }

    /* Try to read 2 bytes. This is also safe for LM75 */
    if (write( file, buf, bytes.length() ) != bytes.length())
    {
        close(file);
        fprintf(stderr,"write error\n");
        emit i2cError();
        return;
    }

    close(file);

    fprintf(stderr,"write ok\n");

    emit i2cWriteOk();

}

/*
 * I2C Read function
 *
 */

void I2cif::i2cRead(QString devName, unsigned char address, int count)
{
    int file;
    char buf[200];
    Conv conv;

    m_readResult = "";
    //emit i2cReadResultChanged();

    QByteArray tmpBa = devName.toUtf8();
    const char* devNameChar = tmpBa.constData();

    fprintf(stderr, "reading from address %02x count %d\n", address, count);

    if ((file = open (devNameChar, O_RDWR)) < 0)
    {
        fprintf(stderr,"open error\n");
        emit i2cError();
        return;
    }

    if (ioctl(file, I2C_SLAVE, address) < 0)
    {
        close(file);
        fprintf(stderr,"ioctl error\n");
        emit i2cError();
        return;
    }

    /* Try to read 2 bytes. This is also safe for LM75 */
    if (read( file, buf, count ) != count)
    {
        close(file);
        fprintf(stderr,"read error\n");
        emit i2cError();
        return;
    }

    close(file);

    /* copy buf to m_readResult */
    int i;

    fprintf(stderr, "read ");
    for (i=0; i<count ; i++)
    {
        m_readResult = m_readResult + conv.toHex(buf[i],2) + " ";
        fprintf(stderr, "%02x ", buf[i]);
    }
    fprintf(stderr, "\n");

    emit i2cReadResultChanged();
}

/*
 * Simple probing function to check its presence in I2C bus
 *
 * Returns a string through i2cProbingStatus()
 * emits a i2cProbingChanged() signal when complete
 *
 * "ok" - reading 2 bytes was succesful
 * "openFail - open() command faild to open device
 * "ioctlFail" - ioctl() to slave address failed
 * "readFail" - read() 2 bytes from slave failed (basically NACK)
 *
 */

void I2cif::i2cProbe(QString devName, unsigned char address)
{
    int file;
    char buf[2];

    m_probingResult = "busy";

    QByteArray tmpBa = devName.toUtf8();
    const char* devNameChar = tmpBa.constData();

    fprintf(stderr, "probing %s address %02x: ", devNameChar, address);

    if ((file = open (devNameChar, O_RDWR)) < 0)
    {
        m_probingResult = "openFail";
        fprintf(stderr, "open failed\n");
        emit i2cProbingChanged();
        return;
    }

    if (ioctl(file, I2C_SLAVE, address) < 0)
    {
        close(file);
        m_probingResult = "ioctlFail";
        fprintf(stderr, "ioctl failed\n");
        emit i2cProbingChanged();
        return;
    }

    /* Try to read 2 bytes. This is also safe for LM75 */
    if (read( file, buf, 2 ) != 2)
    {
        close(file);
        m_probingResult = "readFail";
        fprintf(stderr, "read failed\n");
        emit i2cProbingChanged();
        return;
    }

    close(file);
    m_probingResult = "ok";
    fprintf(stderr, "device found at address %02x\n", address);
    emit i2cProbingChanged();

}



