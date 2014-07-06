# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = i2ctool

CONFIG += sailfishapp

SOURCES += src/i2ctool.cpp \
	src/i2cif.cpp \
    src/conv.cpp
	
HEADERS += src/i2cif.h \
    src/conv.h

OTHER_FILES += qml/i2ctool.qml \
    qml/cover/CoverPage.qml \
    qml/pages/Mainmenu.qml \
    rpm/i2ctool.spec \
	i2ctool.png \
    i2ctool.desktop \
    qml/pages/Probe.qml \
    qml/pages/ReaderWriter.qml \
    qml/i2ctool.png

