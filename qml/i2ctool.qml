
import QtQuick 2.0
import Sailfish.Silica 1.0



ApplicationWindow
{
    _defaultPageOrientations: Orientation.All

    property bool openingUsersGuide: false

    initialPage: Qt.resolvedUrl("pages/Mainmenu.qml")
    cover: Qt.resolvedUrl("cover/CoverPage.qml")

    onApplicationActiveChanged:
    {
        if (!applicationActive && openingUsersGuide)
        {
            openingUsersGuide = false
        }
    }

}
