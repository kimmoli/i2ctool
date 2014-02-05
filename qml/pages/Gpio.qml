
import QtQuick 2.0
import Sailfish.Silica 1.0
import i2ctool.I2cif 1.0
import i2ctool.Conv 1.0


Page
{
    id: gpioPage

    SilicaFlickable
    {
        anchors.fill: parent
        contentHeight: column.height

        Column
        {
            id: column

            width: parent.width
            spacing: 0
            property string colTitle: "GPIO Control"
            PageHeader
            {
                title: parent.colTitle
            }

            TextSwitch
            {
                id: dirIn
                checked: true
                text: (checked ? "Input" : "Output")
                description: "GPIO pin direction"
                onClicked:
                {
                    i2cif.gpioDirInput( checked )
                    i2cif.gpioRequestValue()
                }
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextSwitch
            {
                id: outVal
                checked: false
                text: (checked ? "high" : "low")
                description: "Output state"
                visible: !dirIn.checked
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked:
                {
                    i2cif.gpioSetValue( checked )
                    i2cif.gpioRequestValue()
                }
            }

            Label
            {
                text: "Current value = " + (i2cif.gpioValue ? "high" : "low")
                width: parent.width - 100
                anchors.horizontalCenter: parent.horizontalCenter
            }


        }
    }

    I2cif
    {
        id: i2cif
    }

    Timer
    {
        interval: 100
        running: dirIn.checked
        repeat: true
        onTriggered: i2cif.gpioRequestValue()
    }

    Conv
    {
        id: conv
    }

}
