
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.i2ctool.I2cif 1.0
import harbour.i2ctool.Conv 1.0


Page
{
    id: rwPage
    property string deviceName : "/dev/i2c-1"
    property string cfgAddr : "0"

    property string result : "Unknown"
    property string state : "Unknown"
    property string addr : "50"

    function sleep(milliseconds)
    {
      var start = new Date().getTime();
      for (;;)
      {
        if ((new Date().getTime() - start) > milliseconds)
        {
          break;
        }
      }
    }

    Component.onCompleted:
    {
        state = "readHeader"
        /* Set read pointer to 0 */
        i2cif.i2cWrite(deviceName, conv.toInt(addr), cfgAddr)
        /* Read whole header of 15 bytes */
        i2cif.i2cRead(deviceName, conv.toInt(addr), 64)
    }

    SilicaFlickable
    {
        id: sf

        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator { flickable: sf }

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
                text: "Show, edit and program TOH EEPROM config_data area contents"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle
            {
                id: spacerOne
                color: "transparent"
                height: 50
                width: parent.width
                Label
                {
                    id: errorLabel
                    color: "red"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "EEPROM not found"
                    visible: false
                    anchors.centerIn: parent
                }
            }


            Repeater
            {
                id: dataView

                model: eepromCfgData

                width: parent.width

                delegate: BackgroundItem
                {
                    id: dataItem
                    width: parent.width
                    height: Theme.itemSizeSmall
                    onClicked: editData()

                    function editData()
                    {
                        var editDialog = pageStack.push(Qt.resolvedUrl("EditHeaderEntry.qml"),
                                                    {"headerTitle": headerTitle,
                                                     "headerValue": headerValue,
                                                     "len": String(headerValue).length })

                        editDialog.accepted.connect( function()
                        {
                            console.log("dialog accepted for index " + index)
                            console.log(" title is " + editDialog.headerTitle)
                            console.log(" value is " + editDialog.headerValue)

                            dataView.model.setProperty(index, "headerValue", editDialog.headerValue)
                        })
                    }


                    Row
                    {
                        anchors.verticalCenter: parent.verticalCenter
                        x: Theme.paddingMedium
                        width: parent.width - 3*Theme.paddingMedium
                        spacing: width - headerTitleLabel.width - headerValueLabel.width

                        Label
                        {
                            id: headerTitleLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: headerTitle
                        }
                        Label
                        {
                            id: headerValueLabel
                            anchors.verticalCenter: parent.verticalCenter
                            text: headerValue
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Theme.fontSizeExtraLarge
                        }
                    }

                }
            }
            Button
            {
                id: writeButton
                text: "Write"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    console.log(eepromCfgData.count)

                    var address = conv.toInt(cfgAddr.substring(2))

                    for (var m = 0 ; m<8; m++)
                    {
                        var data = conv.toHex((address + m*8),2)

                        for (var n = 0 ; n<4; n++)
                        {
                            var tmp = eepromCfgData.get((m*4)+n).headerValue
                            data += " " + String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3)
                        }

                        i2cif.i2cWrite(deviceName, conv.toInt(addr), data)
                        sleep(50)

                    }

                }
            }
        }
    }

    ListModel
    {
        id: eepromCfgData
    }

    I2cif
    {
        id: i2cif
        onI2cError:
        {
            writeButton.visible = false
            errorLabel.visible = true
        }

        onI2cReadResultChanged:
        {
            if (state === "Unknown")
            {
                console.log("Unknown read??")
                console.log(i2cif.i2cReadResult)
            }

            if (state === "readHeader")
            {
                var header = i2cif.i2cReadResult.split(' ')

                for (var i=0;i<32;i++)
                {
                    var headerData = String(header[(2*i)]) + String(header[(2*i)+1])
                    eepromCfgData.append({ "headerTitle": ("Parameter " + i), "headerValue": headerData})
                }

            }
            state = "Unknown"
        }
    }

    Conv
    {
        id: conv
    }

}
