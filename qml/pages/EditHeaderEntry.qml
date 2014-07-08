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
            valueValidator.regExp = /[a-fA-F0-9]{1,2}/
        else
            valueValidator.regExp = /[a-fA-F0-9]{1,4}/
    }

    onAccepted:
    {
        var tmp = valueField.text

        for (; tmp.length < len ;)
            tmp = '0' + tmp

        headerValue = tmp
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
            onTextChanged:
            {
                valueField.text = String(valueField.text).toUpperCase()
                editValueDialog.canAccept = (text.length > 0) && (text.length <= len)
            }
            inputMethodHints: Qt.ImhUppercaseOnly | Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            validator: RegExpValidator { id: valueValidator }
            EnterKey.enabled: (text.length > 0) && (text.length <= len)
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: editValueDialog.accept()
        }

    }


}
