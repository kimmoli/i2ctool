
import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground
{
    Image
    {
        source: "../i2ctool.png"
        anchors.centerIn: parent

        Label
        {
            id: label
            anchors.top: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "I2C Tool"
        }
    }


}


