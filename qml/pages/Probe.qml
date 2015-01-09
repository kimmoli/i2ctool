
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.i2ctool.Conv 1.0
import harbour.i2ctool.I2cif 1.0

Page
{
    id: probePage
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
            property string colTitle: "Scanning..."
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
                        property color textcol: Theme.highlightColor
                        Text
                        {
                            anchors.centerIn: parent
                            color: parent.textcol
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

        Component.onCompleted: i2cif.i2cProbe(deviceName)

        onI2cProbingChanged:
        {
            var results = i2cif.i2cProbingStatus;
            for (var i=0 ; i<i2cif.i2cProbingStatus.length ; i++)
            {
                var res = results[i]
                var tmp = addressGrid.itemAt(i)

                if (res === "openFail")
                {
                    tmp.color = "red"
                    tmp.textcol = "white"
                }
                else if (res === "ioctlFail")
                {
                    tmp.color = "blue"
                    tmp.textcol = "white"
                }
                else if (res === "readFail")
                {
                    tmp.color = "yellow"
                    tmp.textcol = "black"
                }
                else if (res === "ok")
                {
                    tmp.color = "green"
                    tmp.textcol = "white"
                }
                else if (res === "skipped")
                {
                    tmp.color = "black"
                    tmp.textcol = "white"
                }
            }

            column.colTitle = "Probe for " + deviceName

        }
    }
}
