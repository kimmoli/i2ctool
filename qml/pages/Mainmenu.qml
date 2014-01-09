
import QtQuick 2.0
import Sailfish.Silica 1.0
import i2ctool.I2cif 1.0

Page
{
    id: mainMenuPage

    SilicaFlickable
    {
        anchors.fill: parent

        contentHeight: column.height

        Column
        {
            id: column

            width: mainMenuPage.width
            spacing: Theme.paddingLarge
            PageHeader
            {
                title: "I2C Tool"
            }

            ComboBox
            {
                id: devname
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Device: "
                currentIndex: 1
                menu: ContextMenu
                {
                    MenuItem { text: "/dev/i2c-0" }
                    MenuItem { text: "/dev/i2c-1" }
                    MenuItem { text: "/dev/i2c-3" }
                    MenuItem { text: "/dev/i2c-4" }
                    MenuItem { text: "/dev/i2c-12" }
                }
            }


            Row
            {
                anchors.horizontalCenter: parent.horizontalCenter
                Button
                {
                    text: "enable Vdd"
                    onClicked: i2cif.tohVddSet("on")
                }
                Button
                {
                    text: "disable Vdd"
                    onClicked: i2cif.tohVddSet("off")
                }

            }

            Button
            {
                text: "Probe"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("Probe.qml"), {deviceName: devname.value})
            }

            Button
            {
                text: "Reader/Writer"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("ReaderWriter.qml"), {deviceName: devname.value})
            }


            Rectangle
            {
                height: 50
                width: 1
                color: "transparent"
            }

            Image {
                source: "../i2ctool.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Label
            {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "I2C Tool"
            }
            Label
            {
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                text: "(C) 2013 Kimmoli"
            }

        }
    }

    I2cif
    {
        id: i2cif
    }

}


