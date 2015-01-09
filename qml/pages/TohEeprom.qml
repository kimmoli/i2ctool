
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.i2ctool.I2cif 1.0
import harbour.i2ctool.Conv 1.0


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

    property bool writeButtonPressed: false

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

    function initReadHeader()
    {
        i2cif.unbindTohCore() // This works only if root
        sleep(100)
        state = "readHeader"
        /* Set read pointer to 0 */
        i2cif.i2cWrite(deviceName, conv.toInt(addr), "0")
        /* Read whole header of 15 bytes */
        i2cif.i2cRead(deviceName, conv.toInt(addr), 15)
    }

    function readHeader()
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

        eepromData.clear()

        for (var i=0;i<headerData.length;i++)
        {
            eepromData.append({ "headerTitle": headerTitle[i], "headerValue": headerData[i]})
        }

    }

    Component.onCompleted:
    {
        initReadHeader()
    }

    RemorsePopup
    {
        id: remorse
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu
        {

            MenuItem
            {
                text: "Set these as default values"
                onClicked:
                    remorse.execute("Overwriting in", function()
                        {
                            for (var n=0; n<8; n++)
                                i2cif.setAsDefault(n, dataView.model.get(n).headerValue)
                        })
            }
            MenuItem
            {
                text: "Re-read from EEPROM"
                onClicked:
                {
                    initReadHeader()
                }
            }

            MenuItem
            {
                text: "Change EEPROM address"
                onClicked:
                {
                    var editDialog = pageStack.push(Qt.resolvedUrl("EditHeaderEntry.qml"),
                                                {"headerTitle": "EEPROM Address",
                                                 "headerValue": addr,
                                                 "len": 2 })

                    editDialog.accepted.connect( function()
                    {
                        if (conv.toInt(addr) > 0 && conv.toInt(addr) < 128)
                        {
                            addr = editDialog.headerValue
                            initReadHeader()
                        }
                    })
                }
            }

            MenuItem
            {
                text: "Edit CFG section"
                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl("TohEepromCfgEdit.qml"), {deviceName: "/dev/i2c-1",
                                   cfgAddr: dataView.model.get(4).headerValue, addr: addr})
                }
            }

            MenuItem
            {
                text: "Fill with defaults"
                onClicked:
                {
                    if (dataView.model.count === 0)
                        for (var i=0;i<8;i++)
                        {
                            dataView.model.append({ "headerTitle": headerTitle[i], "headerValue": "0"})
                        }
                    for (var n=0; n<8; n++)
                        dataView.model.setProperty(n, "headerValue", i2cif.getDefault(n))
                }
            }
        }

        Column
        {
            id: column

            width: parent.width
            spacing: 0
            property string colTitle: "EEPROM 0x" + addr
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
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "EEPROM not found"
                    visible: false
                    anchors.centerIn: parent
                }
                Label
                {
                    id: writeErrorLabel
                    color: "red"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "Write failed"
                    visible: false
                    anchors.centerIn: parent
                    onVisibleChanged: if (visible) writeResultLabelHide.start()
                }
                Label
                {
                    id: writeSuccessLabel
                    color: "light green"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeExtraLarge
                    text: "Write OK"
                    visible: false
                    anchors.centerIn: parent
                    onVisibleChanged: if (visible) writeResultLabelHide.start()
                }
                Timer
                {
                    id: writeResultLabelHide
                    interval: 2500
                    running: false
                    repeat: false
                    onTriggered:
                    {
                        writeSuccessLabel.visible = false
                        writeErrorLabel.visible = false
                    }
                }

            }


            Repeater
            {
                id: dataView

                model: eepromData

                width: parent.width

                delegate: BackgroundItem
                {
                    id: dataItem
                    width: column.width
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
                id: retryButton
                text: "Retry read"
                anchors.horizontalCenter: parent.horizontalCenter
                visible: errorLabel.visible
                onClicked: initReadHeader()
            }

            Button
            {
                id: writeButton
                text: "Write"
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: !writeErrorLabel.visible && !writeSuccessLabel.visible
                onClicked:
                {
                    i2cif.unbindTohCore() // This works only if root
                    sleep(100)

                    console.log(eepromData.count)
                    writeButtonPressed = true

                    var data = "00 "
                    var tmp = eepromData.get(0).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    tmp = eepromData.get(1).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    tmp = eepromData.get(2).headerValue
                    data += String(tmp) + " "

                    tmp = eepromData.get(3).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    tmp = eepromData.get(4).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1)

                    i2cif.i2cWrite(deviceName, conv.toInt(addr), data)
                    sleep(50)

                    data = "08 "

                    data += String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    tmp = eepromData.get(5).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    tmp = eepromData.get(6).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    tmp = eepromData.get(7).headerValue
                    data += String(tmp).charAt(0) + String(tmp).charAt(1) + " " + String(tmp).charAt(2) + String(tmp).charAt(3) + " "

                    data += "FF"

                    writeButtonPressed = true
                    i2cif.i2cWrite(deviceName, conv.toInt(addr), data)
                    sleep(50)

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
            errorLabel.visible = false

            if (writeButtonPressed)
            {
                writeErrorLabel.visible = true
                writeButtonPressed = false
            }
            else
            {
                writeButton.visible = false
                errorLabel.visible = true
            }
        }

        onI2cWriteOk:
        {
            errorLabel.visible = false

            if (writeButtonPressed)
            {
                writeSuccessLabel.visible = true
                writeButtonPressed = false
            }
            writeButton.visible = true
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
                readHeader()
            }
            state = "Unknown"
        }
    }

    Conv
    {
        id: conv
    }

}
