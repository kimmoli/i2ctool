
import QtQuick 2.0
import Sailfish.Silica 1.0
import i2ctool.I2cif 1.0
import i2ctool.Conv 1.0


Page
{
    id: rwPage
    property string deviceName : "/dev/i2c-1"
    property string result : "Unknown"

    function go(devName, addr, mode, wD, rC)
    {
        if (mode === 0 || mode === 2) // write
        {
            console.log("writing")
            i2cif.i2cWrite(devName, conv.toInt(addr), wD)
        }
        if (mode === 1 || mode === 2) // read
        {
            console.log("reading")
            i2cif.i2cRead(devName, conv.toInt(addr), rC)
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        Column
        {
            id: column

            width: parent.width
            spacing: 0
            property string colTitle: "Reader/Writer"
            PageHeader
            {
                title: parent.colTitle
            }

            Label
            {
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Address and data in hex. Separate databytes with space. Bytecount in decimal."
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }
            Rectangle
            {
                color: "transparent"
                height: 50
                width: 1
            }

            TextField
            {
                id: address
                placeholderText: "Enter device address"
                inputMethodHints: Qt.ImhPreferUppercase| Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                width: parent.width - 100
                validator: RegExpValidator { regExp: /[0-9a-fA-F]{1,2}/ }
                anchors.horizontalCenter: parent.horizontalCenter
                EnterKey.onClicked: focus = false
            }
            ComboBox
            {
                id: mode
                width: parent.width - 100
                label: "Mode"
                anchors.horizontalCenter: parent.horizontalCenter
                currentIndex: 1
                menu: ContextMenu
                {
                    MenuItem { text: "Write" }
                    MenuItem { text: "Read" }
                    MenuItem { text: "Write then read" }
                }
            }
            TextField
            {
                id: writeData
                visible: mode.currentIndex === 0 || mode.currentIndex === 2
                placeholderText: "Enter databytes to write"
                inputMethodHints: Qt.ImhPreferUppercase| Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                validator: RegExpValidator { regExp: /^[a-fA-F0-9]{1,2}(\s+[a-fA-F0-9]{1,2})*$/ }
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                EnterKey.onClicked: focus = false
            }
            TextField
            {
                id: readCount
                visible: mode.currentIndex === 1 || mode.currentIndex === 2
                placeholderText: "Enter number of bytes to read"
                inputMethodHints: Qt.ImhDigitsOnly
                validator: RegExpValidator { regExp: /\d+/ }
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                EnterKey.onClicked: focus = false
            }

            Button
            {
                text: mode.currentIndex === 0 ? "Write" : (mode.currentIndex === 1 ? "Read" : "Write and read")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    result = "RUNNING"
                    go(deviceName, address.text, mode.currentIndex, writeData.text, readCount.text)
                }
            }

            Label
            {
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Status: " +  result
            }
            Label
            {
                id: readBytes
                visible: mode.currentIndex === 1 || mode.currentIndex === 2
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.Wrap
                text: i2cif.i2cReadResult
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
