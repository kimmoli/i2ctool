
import QtQuick 2.0
import Sailfish.Silica 1.0
import i2ctool.I2cif 1.0
import i2ctool.Conv 1.0


Page
{
    id: rwPage
    property string deviceName : "/dev/i2c-1"

    property string result : "Unknown"
    property string state : "Unknown"
    property string addr : "50"

    property var headerData: []
    property var headerTitle: [ "Vendor ID",
                                "Product ID",
                                "Revision",
                                "EEPROM Size",
                                "CFG Addr",
                                "CFG Size",
                                "UDATA Addr",
                                "UDATA Size" ]


    Component.onCompleted:
    {
        state = "readHeader"
        /* Set read pointer to 0 */
        i2cif.i2cWrite(deviceName, conv.toInt(addr), "0")
        /* Read whole header of 15 bytes */
        i2cif.i2cRead(deviceName, conv.toInt(addr), 15)
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu
        {
            MenuItem
            {
                text: "Fill with some default"
                onClicked:
            }
        }

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
                text: "Show, edit and program\nTOH EEPROM contents"
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
                    text: "EEPROM not found"
                    visible: false
                }
            }


            ListView
            {
                id: dataView

                model: eepromData

                width: parent.width
                height: Theme.itemSizeSmall * count
                clip: true

                delegate: BackgroundItem
                {
                    id: dataItem
                    width: ListView.view.width
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
                    console.log(eepromData.count)
                    var data = "00 "
                    for (var i=0; i<eepromData.count; i++)
                    {
                        var tmp = eepromData.get(i).headerValue
                        if (tmp.length === 4)
                        {
                            data += String(tmp).charAt(0)
                            data += String(tmp).charAt(1)
                            data += " "
                            data += String(tmp).charAt(2)
                            data += String(tmp).charAt(3)
                        }
                        else
                            data += String(tmp)

                        if ((i+1)<eepromData.count)
                            data += " "
                    }
                    i2cif.i2cWrite(deviceName, conv.toInt(addr), data)
                }
            }
        }
    }

    ListModel
    {
        id: eepromData
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
                /*
                    { TOH_EEPROM_VENDOR, 2, 0 },
                    { TOH_EEPROM_PRODUCT, 2, 2 },
                    { TOH_EEPROM_REV, 1, 4 },
                    { TOH_EEPROM_EEPROM_SIZE, 2, 5 },
                    { TOH_EEPROM_CFG_ADDR, 2, 7 },
                    { TOH_EEPROM_CFG_SIZE, 2, 9 },
                    { TOH_EEPROM_UDATA_ADDR, 2, 11 },
                    { TOH_EEPROM_UDATA_SIZE, 2, 13 },
                */


                headerData[0] = String(header[0]) + String(header[1])
                headerData[1] = String(header[2]) + String(header[3])
                headerData[2] = String(header[4])
                headerData[3] = String(header[5]) + String(header[6])
                headerData[4] = String(header[7]) + String(header[8])
                headerData[5] = String(header[9]) + String(header[10])
                headerData[6] = String(header[11]) + String(header[12])
                headerData[7] = String(header[13]) + String(header[14])

                console.log(headerTitle)
                console.log(headerData)

                for (var i=0;i<headerData.length;i++)
                {
                    eepromData.append({ "headerTitle": headerTitle[i], "headerValue": headerData[i]})
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
