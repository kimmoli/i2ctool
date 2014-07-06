import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog
{
    id: editValueDialog

    canAccept: false

    property string headerTitle: "title"
    property string headerValue: "value"
    property int len: 4

    Component.onCompleted:
    {
        valueField.text = headerValue
        if (len === 2)
            valueValidator.regExp = /[A-F0-9]{2}/
        else
            valueValidator.regExp = /[A-F0-9]{4}/
    }

    onAccepted:
    {
        headerValue = valueField.text
    }

    DialogHeader
    {
        id: pageHeader
        title: "Edit"
    }

    Column
    {
        id: col
        spacing: Theme.paddingSmall
        width: editValueDialog.width
        anchors.top: pageHeader.bottom

        Label
        {
            text: headerTitle
            width: parent.width
            x: Theme.paddingLarge
            font.bold: true
        }


        TextField
        {
            id: valueField
            text: headerValue
            focus: true
            width: parent.width
            label: "value"
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.primaryColor
            placeholderText: qsTr("Enter new value here")
            onTextChanged: editValueDialog.canAccept = text.length === len
            inputMethodHints: Qt.ImhUppercaseOnly | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            validator: RegExpValidator { id: valueValidator }
            EnterKey.enabled: text.length === len
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: editValueDialog.accept()
        }

    }


}
