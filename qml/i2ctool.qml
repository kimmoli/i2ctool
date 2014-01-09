
import QtQuick 2.0
import Sailfish.Silica 1.0

import "pages"

ApplicationWindow
{
    initialPage: Component { Mainmenu { id: mainMenuPage } }
    Component { Probe { id: probePage } }

    cover: Qt.resolvedUrl("cover/CoverPage.qml")



}


