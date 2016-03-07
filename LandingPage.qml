import QtQuick 2.3
import QtQuick.Controls 1.2

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0

Item {
    id: landingPage
    property color backGroundColor: "#5F9EA0"
    property string titleText: "LatestFires"
    signal signInClicked()

    Rectangle {
        anchors.fill: parent
        color: landingPage.backGroundColor
        Image {
            source: "assets/images/wildfire.jpg"
            width: Math.round(parent.height * app.width/app.height)
            height: Math.round(parent.width * app.height/app.width)
        }
    }

    Rectangle {
        id: headerItem
        width: parent.width
        height: Math.round(0.10 * parent.height)
        anchors.top: parent.top
        color: app.themeColor
        gradient: Gradient {
            GradientStop { position: 1.0; color: "white" }
            GradientStop { position: 0.0; color: app.themeColor }
        }

        Text {
            id: title
            anchors.centerIn: parent
            text: landingPage.titleText
            font.pointSize: Math.round(0.40 * parent.height)
        }

    }

    ImageButton {
        id: signInButton
        anchors.centerIn: parent
        width: 160 * AppFramework.displayScaleFactor
        height: 80 * AppFramework.displayScaleFactor
        enabled: AppFramework.network.isOnline
        source: AppFramework.network.isOnline ? "assets/images/startbutton.png"
                : "assets/images/networkOffline.png"
        onClicked: {
            signInClicked();
        }
    }

    Rectangle {
        id: footerItem
        width: parent.width
        height: Math.round(0.10 * parent.height)
        anchors.bottom: parent.bottom
        gradient: Gradient {
            GradientStop { position: 0.0; color: "white" }
            GradientStop { position: 1.0; color: app.themeColor }
        }
    }

}

