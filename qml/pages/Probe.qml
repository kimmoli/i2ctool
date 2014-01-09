
import QtQuick 2.0
import Sailfish.Silica 1.0
import i2ctool.I2cif 1.0
import i2ctool.Conv 1.0


Page
{
    id: probePage
    property int address: 0
    property string deviceName: "/dev/i2c-1"

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        Column
        {
            id: column

            width: parent.width
            spacing: 0
            property string colTitle: "Scanning 0x" + conv.toHex(address, 2)
            PageHeader
            {
                title: parent.colTitle
            }

            Grid
            {
                columns: 8
                Repeater
                {
                    id: addressGrid
                    model: 128

                    Rectangle
                    {
                        width: probePage.width/8
                        height: probePage.height/20
                        radius: 10
                        color: "transparent"
                        border.color: Theme.highlightColor
                        Text
                        {
                            anchors.centerIn: parent
                            color: Theme.highlightColor
                            font.bold: true
                            text: conv.toHex(index, 2)
                        }
                    }
                }
            }

        }
    }

    Conv
    {
        id: conv
    }

    I2cif
    {
        id: i2cif

        onI2cProbingChanged:
        {
            var tmp = addressGrid.itemAt(address)
            var res = i2cif.i2cProbingStatus;
            if (res === "openFail")
                tmp.color = "red"
            else if (res === "ioctlFail")
                tmp.color = "blue"
            else if (res === "readFail")
                tmp.color = "yellow"
            else if (res === "ok")
                tmp.color = "green"

            address++
            if (address < 128)
                scanTimer.start()
            else
                column.colTitle = deviceName + " scanned"

        }
    }


    Timer
    {
        id: scanTimer
        running: applicationActive && probePage.status === PageStatus.Active
        repeat: false
        interval: 100
        onTriggered:
        {
            if (address < 128)
            {
                i2cif.i2cProbe(deviceName, address)
            }
        }
    }

}
