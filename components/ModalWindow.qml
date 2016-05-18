import QtQuick 2.3
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.2


Item {
    id: modalWindow

    property alias dataModel: dataModel
    property double scaleFactor: 1.00
    property color titleBackGroundColor: "#3E2723"
    property color backgroundColor: "#EFEBE9"
    property color titleTextColor: "white"
    property color shadowColor: Qt.rgba(0, 0, 0, 0.2)
    property real shadowVerticalOffset: 5
    property real shadowHorizontalOffset: 5
    property real defaultMargins: 8 * scaleFactor
    property double baseFontSize: 18 * scaleFactor

    width: Math.min(parent.width/1.2, 350 * scaleFactor)
    height: Math.min(0.8 * parent.height, 400 * scaleFactor)
    anchors.centerIn: parent
    opacity: visible ? 1 : 0
    visible: false
    focus: visible
    z: 20

    MouseArea {
        anchors.fill: parent
        onWheel: wheel.accepted = true // prevent mouse scroll from scrolling background map
    }

    DropShadow {
        anchors.fill: modalWindow
        horizontalOffset: shadowHorizontalOffset
        verticalOffset: shadowVerticalOffset
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
            Layout.preferredHeight: 60 * scaleFactor
            z: 30

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
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
                    pixelSize: baseFontSize * 1.1
                }
                color: titleTextColor
                maximumLineCount: 1
                elide: Text.ElideRight
                anchors.leftMargin: defaultMargins
            }

            Button {
                Rectangle {
                    // This rectangle ensures the button has a background color
                    anchors.fill: parent
                    radius: 3
                    color: "white"
                }
                Image {
                    source: "img/close_button.png"
                    anchors.fill: parent
                }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    propagateComposedEvents: true
                }
                height: parent.height/3
                width: parent.height/3
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: defaultMargins
                z: modalWindow.z + 1
                opacity: modalWindow.opacity
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
            color: backgroundColor
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
                    height: headerBar.height * 2
                    border.color: titleBackGroundColor
                    color: "white"
                    Image {
                        id: ptSymbol
                        width: 11.2 * scaleFactor
                        height: 11.2 * scaleFactor
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: defaultMargins
                        source: img_path
                    }
                    Text {
                        id: listTitle
                        anchors.top: parent.top
                        anchors.left: ptSymbol.right
                        anchors.margins: defaultMargins * 0.8
                        font.pixelSize: baseFontSize * 0.7
                        font.bold: true
                        text: record_age === 1 ? "Detected ~1 hour ago" : "Detected ~" + record_age + " hours ago"
                        wrapMode: Text.WordWrap
                        width: parent.width * 0.8
                    }
                    children: [
                        Text {
                            id: listItem1
                            anchors.top: listTitle.bottom
                            anchors.margins: defaultMargins * 0.8
                            anchors.left: listTitle.left
                            font.pixelSize: baseFontSize * 0.7
                            text: "Location -> (%1°, %2°)".arg(latitude).arg(longitude)
                            wrapMode: Text.WordWrap
                            width: parent.width * 0.9
                        },
                        Text {
                            id: listItem2
                            anchors.top: listItem1.bottom
                            anchors.margins: defaultMargins * 0.8
                            anchors.left: listTitle.left
                            font.pixelSize: baseFontSize * 0.7
                            text: "Detection Confidence = %1%".arg(confidence)
                            wrapMode: Text.WordWrap
                            width: parent.width * 0.9
                        },
                        Text {
                            id: listItem3
                            anchors.top: listItem2.bottom
                            anchors.margins: defaultMargins * 0.8
                            anchors.left: listTitle.left
                            font.pixelSize: baseFontSize * 0.7
                            text: satellite === "A" ? "Satellite platform = Aqua" : "Satellite platform = Terra"
                            wrapMode: Text.WordWrap
                            width: parent.width * 0.9
                        },
                        Text {
                            id: listItem4
                            anchors.top: listItem3.bottom
                            anchors.margins: defaultMargins * 0.8
                            anchors.left: listTitle.left
                            font.pixelSize: baseFontSize * 0.7
                            text: "Fire radiative power = " + frp + "MW"
                            wrapMode: Text.WordWrap
                            width: parent.width * 0.9
                        }
                    ]
                }
            }
        }
    }
}
