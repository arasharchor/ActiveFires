import QtQuick 2.3
import QtQuick.Controls 1.4


Item {
    id: splashPage

    property string logoImgPath: "thumbnail.png"
    property string landingPage: "MapPage.qml"

    anchors.fill: parent

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: landingPage

        Rectangle {
            id: background
            anchors.fill: parent
            color: app.config.backgroundColor

            BusyIndicator {
                id: busyIndicator
                //running: image.status === Image.Loading
                anchors.top: parent.top
                anchors.margins: app.config.defaultMargins * 10
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Image {
                id: logo
                anchors.centerIn: parent
                source: logoImgPath
                fillMode: Image.PreserveAspectFit
            }

            Text {
                id: versionText
                anchors.top: logo.bottom
                anchors.margins: app.config.defaultMargins
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "%1 %2".arg(app.config.appName).arg(app.info.version)
                font.family: app.config.mainFontFamily.name
                font.pixelSize: 1.5 * app.config.baseFontSize
                font.bold: true
                wrapMode: Text.WordWrap
                color: app.config.appLabelColor
            }
        }
    }
}
