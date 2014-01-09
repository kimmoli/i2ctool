
#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#include <sailfishapp.h>
#include <QtQml>
#include <QScopedPointer>
#include <QQuickView>
#include <QQmlEngine>
#include <QGuiApplication>
#include <QQmlContext>
#include <QCoreApplication>
#include "i2cif.h"
#include "conv.h"


int main(int argc, char *argv[])
{
    qmlRegisterType<I2cif>("i2ctool.I2cif", 1, 0, "I2cif");
    qmlRegisterType<Conv>("i2ctool.Conv", 1, 0, "Conv");

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    view->setSource(SailfishApp::pathTo("qml/i2ctool.qml"));
    view->show();

    return app->exec();
}

