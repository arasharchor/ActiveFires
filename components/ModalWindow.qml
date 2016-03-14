import QtQuick 2.3
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0


Item {
    id: modalWindow

    property color themeColor: app.themeColor
    property alias dataModel : dataModel
    property double scaleFactor: AppFramework.displayScaleFactor
    property color titleBackGroundColor: "#444"
    property color backGroundColor: "white"
    property color titleTextColor: "white"
    property color shadowColor: "#80000000"
    property double baseFontSize: 18

    width: Math.round(parent.width/1.5)
    height: Math.round(0.9 * parent.height)
    anchors.centerIn: parent
    opacity: visible ? 1 : 0
    visible: false
    focus: visible
    z: 100

    DropShadow {
        anchors.fill: modalWindow
        horizontalOffset: 5
        verticalOffset: 5
        radius: 8.0
        samples: 16
        color: shadowColor
        source: modalWindow
    }

    Behavior on opacity {
        NumberAnimation { property: "opacity"; to:1;  duration: 250; }
    }

    ListModel {
        id: dataModel
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: headerBar
            color: titleBackGroundColor
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: Math.round(0.2*parent.height)
            z: 110

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            Text {
                id: titleText
                text: dataModel.count > 1 ? dataModel.count + " Points Selected" : dataModel.count + " Point Selected"
                textFormat: Text.StyledText
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font {
                    pointSize: baseFontSize * 1.1
                }
                color: titleTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: 8*scaleFactor
            }

            ImageButton {
                source: app.folder.fileUrl("assets/images/closebutton.png")
                opacity: modalWindow.opacity
                height: 30 * scaleFactor
                width: 30 * scaleFactor
                z: modalWindow.z + 1
                checkedColor : "transparent"
                pressedColor : "transparent"
                hoverColor : "transparent"
                glowColor : "transparent"
                anchors.rightMargin: 10*scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                onClicked: {
                    opacity = 0
                    modalWindow.opacity = 0
                    modalWindow.visible = false
                }
                Behavior on opacity { NumberAnimation { property: "opacity"; to: 1; duration: 500; } }
            }
        }

        Rectangle {
            id: modalWindowContainer
            color: backGroundColor
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    mouse.accepted = false
                }
            }

            ListView {
                id: modalListView
                anchors.fill: parent
                contentHeight: parent.height
                model: dataModel
                clip: true
                delegate: Rectangle {
                    width: modalWindow.width
                    height: Math.round(0.25 * modalWindow.height)
                    border.color: headerBar.color
                    Image {
                        id: ptSymbol
                        width: 14
                        height: 14
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: 5
                        source: record_age > 3 ? app.folder.fileUrl("assets/images/fire32x32.png") : app.folder.fileUrl("assets/images/recentfire28x40.png")
                    }
                    Text {
                        id: listTitle
                        anchors.top: parent.top
                        anchors.left: ptSymbol.right
                        anchors.margins: 5
                        font.pointSize: 10
                        font.bold: true
                        text: record_age === 1 ? "Detected 1 hour ago with " + confidence + "% confidence" : "Detected " + record_age + " hours ago with " + confidence + "% confidence"
                    }
                    children: [
                        Text {
                            id: listItem1
                            anchors.top: listTitle.bottom
                            anchors.margins: 5
                            anchors.left: listTitle.left
                            font.pointSize: 10
                            text: satellite === "A" ? "Satellite platform = Aqua" : "Satellite platform = Terra"
                        },
                        Text {
                            id: listItem2
                            anchors.top: listItem1.bottom
                            anchors.margins: 5
                            anchors.left: listTitle.left
                            font.pointSize: 10
                            text: "Fire radiative power = " + frp + "MW"
                        }
                    ]

                }
            }
        }
    }
}
