# I2CTool

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

