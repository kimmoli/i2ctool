#include "i2cif.h"
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <stdio.h>
#include <QCoreApplication>
#include <QSettings>
#include <QProcess>
#include <QThread>
#include <sailfishapp.h>
#include "conv.h"
#include <unistd.h>

I2cif::I2cif(QObject *parent) :
    QObject(parent)
{
    m_probingResult = QStringList();
    m_readResult = "Nothing yet";
    emit tohVddStatusChanged();
}

I2cif::~I2cif()
{
}


QStringList I2cif::i2cProbingStatus()
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

/*
 * Function to check which is current state of Vdd
 *
 */
bool I2cif::tohVddGet()
{
    int fd;
    int retval = 0;
    char buf[1] = { 0 };

    fd = open("/sys/devices/platform/reg-userspace-consumer.0/state", O_RDONLY);

    if (!(fd < 0))
    {
        retval += read(fd, buf ,1);
        close(fd);
    }

    return (buf[0] == 'e'); // values are "enabled" or "disabled"
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

    /* write the data */
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

    /* Read data */
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
 * I2C write then read with repeated stop
 */

void I2cif::i2cWriteThenRead(QString devName, unsigned char address, QString data, int count)
{
    int file;
    Conv conv;
    m_readResult = QString();

    QByteArray tmpBa = devName.toUtf8();
    const char* devNameChar = tmpBa.constData();

    if ((file = open (devNameChar, O_RDWR)) < 0)
    {
        fprintf(stderr,"open error\n");
        emit i2cError();
        return;
    }

    struct i2c_rdwr_ioctl_data i2c_data;
    struct i2c_msg msg[2];
    unsigned char *buftx;
    unsigned char *bufrx;

    bufrx = (unsigned char *)malloc(count +1);

    i2c_data.msgs = msg;
    i2c_data.nmsgs = 2;

    QStringList bytes = data.split(" ");
    int i;
    buftx = (unsigned char *)malloc(bytes.length()+1);
    for (i=0 ; i<bytes.length(); i++)
    {
        bool parseOk;
        QString tmp = bytes.value(i);
        buftx[i] = tmp.toInt(&parseOk, 16);
        if (!parseOk)
        {
            fprintf(stderr, "parsing error %d\n", i);
            emit i2cError();
            return;
        }
        fprintf(stderr, "%02x ", buftx[i]);
    }
    fprintf(stderr, "\n");

    i2c_data.msgs[0].addr = address;
    i2c_data.msgs[0].flags = 0;
    i2c_data.msgs[0].len = bytes.length();
    i2c_data.msgs[0].buf = (unsigned char *)buftx;

    i2c_data.msgs[1].addr = address;
    i2c_data.msgs[1].flags = I2C_M_RD;
    i2c_data.msgs[1].len = count;
    i2c_data.msgs[1].buf = (unsigned char *)bufrx;

    int ret = ioctl(file, I2C_RDWR, &i2c_data);

    if (ret < 0)
    {
            fprintf(stderr, "read data fail %d\n", ret);
            emit i2cError();
            return;
    }

    close(file);

    fprintf(stderr, "read ");
    for (i=0; i<count ; i++)
    {
        m_readResult = m_readResult + conv.toHex(bufrx[i],2) + " ";
        fprintf(stderr, "%02x ", bufrx[i]);
    }
    fprintf(stderr, "\n");

    emit i2cReadResultChanged();

}

/*
 * Simple probing function to check its presence in I2C bus
 *
 * Returns a stringlist through i2cProbingStatus()
 * emits a i2cProbingChanged() signal when complete
 *
 * "ok" - reading 2 bytes was succesful
 * "openFail - open() command faild to open device
 * "ioctlFail" - ioctl() to slave address failed
 * "readFail" - read() 2 bytes from slave failed (basically NACK)
 * "skipped" - addresses 4...7 are skipped to speed up operation
 *
 */

void I2cif::i2cProbe(QString devName)
{
    int file;
    char buf[2];
    unsigned char address;

    m_probingResult.clear();

    for (address = 0; address < 128; address++)
    {

        /* These few addresses takes long time to probe, so skip them brutely */
        if (address >= 4 && address <= 7)
        {
            m_probingResult.append("skipped");
            continue;
        }


        QByteArray tmpBa = devName.toUtf8();
        const char* devNameChar = tmpBa.constData();

        fprintf(stderr, "probing %s address %02x: ", devNameChar, address);

        if ((file = open (devNameChar, O_RDWR)) < 0)
        {
            m_probingResult.append("openFail");
            fprintf(stderr, "open failed\n");
            close(file);
            continue;
        }

        if (ioctl(file, I2C_SLAVE, address) < 0)
        {
            close(file);
            m_probingResult.append("ioctlFail");
            fprintf(stderr, "ioctl failed\n");
            close(file);
            continue;
        }

        /* Try to read 2 bytes. This is also safe for LM75 */
        if (read( file, buf, 2 ) != 2)
        {
            close(file);
            m_probingResult.append("readFail");
            fprintf(stderr, "read failed\n");
            close(file);
            continue;
        }

        close(file);
        m_probingResult.append("ok");
        fprintf(stderr, "device found at address %02x\n", address);
    }

    emit i2cProbingChanged();

}


/*
 *  If microswitch is pressed tohd takes control over i2c-1-0050 (eeprom)
 *  this is used to release it.
 *  but duh, needs to be done as root
 *  echo toh-core.0 > /sys/bus/platform/drivers/toh-core/unbind
*/

void I2cif::unbindTohCore()
{
    int fd;

    fd = open("/sys/bus/platform/drivers/toh-core/unbind", O_WRONLY);

    if (!(fd < 0))
    {
        if (write (fd, "toh-core.0", 10) != 10)
            fprintf(stderr, "unbind failed\n");
        else
            fprintf(stderr, "unbind OK\n");

        close(fd);
    }
    else
        fprintf(stderr, "unbind failed. Did you start i2ctool as root?\n");
}

/*
 * Default values commands
 *
 */

void I2cif::setAsDefault(QString index, QString value)
{
    QSettings s("harbour-i2ctool", "harbour-i2ctool");
    s.beginGroup("Defaults");
    s.setValue(index, value);
    s.endGroup();
}

QString I2cif::getDefault(QString index)
{
    QString value;

    QSettings s("harbour-i2ctool", "harbour-i2ctool");
    s.beginGroup("Defaults");
    value = s.value(index, firstTimeDefault(index)).toString();
    s.endGroup();

    return value;
}

/* helper :) */
QString I2cif::firstTimeDefault(QString index)
{
    if (index == "0") return "4B4C";
    if (index == "1") return "0001";
    if (index == "2") return "01";
    if (index == "3") return "0100";
    if (index == "4") return "0040";
    if (index == "5") return "0040";
    if (index == "6") return "0080";
    if (index == "7") return "0000";
    return "0000";
}

/* use xdg-open to start pdf-viewer for showing usersguide
*/
void I2cif::openUsersGuide()
{
    QProcess proc;
    QString ugpath = SailfishApp::pathTo("i2ctool-ug.pdf").toString();

    fprintf(stderr, "loading user's guide %s\n", qPrintable(ugpath));

    proc.startDetached("/usr/bin/xdg-open" , QStringList() << ugpath);

    QThread::msleep(100);
}
