import QtQuick 2.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0


Item {
    property color themeColor: app.themeColor
    property string titleText: "ActiveFires"
    signal playButtonClicked()

    id: landingPage

    Rectangle {
        id: header
        width: parent.width
        height: Math.round(0.10 * parent.height)
        anchors.top: parent.top
        z: 1

        gradient: Gradient {
            GradientStop { position: 1.0; color: "white" }
            GradientStop { position: 0.0; color: themeColor }
        }

        Text {
            id: title
            anchors.centerIn: parent
            text: titleText
            font.pointSize: Math.round(0.40 * parent.height)
        }

    }


    Rectangle {
        id: background
        anchors.fill: parent

        Image {
            id: backgroundImage
            source: "assets/images/wildfire.jpg"
            width: Math.round(parent.height * app.width/app.height)
            height: Math.round(parent.width * app.height/app.width)

            ImageButton {
                id: playButton
                anchors.centerIn: parent
                anchors.verticalCenter: parent
                width: 160 * AppFramework.displayScaleFactor
                height: 80 * AppFramework.displayScaleFactor
                source: "assets/images/startbutton.png"
                onClicked: {
                    playButtonClicked();
                }
            }
        }
    }


    Rectangle {
        id: footer
        width: parent.width
        height: Math.round(0.10 * parent.height)
        anchors.bottom: parent.bottom

        gradient: Gradient {
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 1.0; color: themeColor }
        }
    }

}

