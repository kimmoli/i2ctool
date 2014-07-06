
import QtQuick 2.0
import Sailfish.Silica 1.0
import i2ctool.I2cif 1.0
import i2ctool.Conv 1.0


Page
{
    id: rwPage
    property string deviceName : "/dev/i2c-1"
    property string result : "Unknown"

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        Column
        {
            id: column

            width: parent.width
            spacing: 0
            property string colTitle: "TOH EEPROM"
            PageHeader
            {
                title: parent.colTitle
            }

            Label
            {
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Show and program vendor and product id of the TOH EEPROM"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle
            {
                color: "transparent"
                height: 50
                width: 1
            }

        }
    }

    I2cif
    {
        id: i2cif
        onI2cError: result = "ERROR"
        onI2cReadResultChanged: result = "OK"
        onI2cWriteOk: result = "OK"
    }

    Conv
    {
        id: conv
    }

}
