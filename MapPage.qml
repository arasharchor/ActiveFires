import QtQuick 2.3
import QtPositioning 5.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4


import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0


import "components"

// TODO: Fix text jumbling up in modal window header
//       Add location
//       Limit pan of map
//       Create config folder with common styles
//       ModalWindow and img in folder of its on
//       Grow modal window from point of clicked
//       Correct record_age in script to round up time properly

Item {

    id: mapPage

    anchors.fill: parent
    signal aboutButtonClicked()

    function defaultView() {
        if (sliderDisplay.y != 0) { sliderDisplay.y = 0 }
        if (modal.visible) { modal.visible = false }
        if (menuWindow.x != app.width) {
            menuWindow.x = app.width
            mapShadow.visible = false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            defaultView()
        }
    }

    Rectangle {
        id: header
        anchors.top: parent.top
        width: parent.width
        height: 60 * app.scaleFactor
        color: app.themeColor
        z: 30 // keeps the shadow visible
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: false
            color: app.shadowColor
            verticalOffset: 4
            horizontalOffset: 1
            samples: 20
            radius: 10.0
            cached: true
        }

        ImageButton {
            id: sliderButton
            width: 38.4 * app.scaleFactor
            height: 38.4 * app.scaleFactor
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: app.defaultMargins
            checkedColor : "transparent"
            pressedColor : app.secondaryColor
            hoverColor : "transparent"
            glowColor : "transparent"
            source: app.imgFolder.arg("slider_xxxhdpi.png")

            onClicked: {
                mapPage.defaultView() // First hide other open windows
                sliderDisplay.y > 0 ? sliderDisplay.y = 0 : sliderDisplay.y = header.height
            }
        }

        Text {
            id: sliderLabel

            anchors.centerIn: parent
            width: parent.width - menuButton.width - sliderButton.width - 8.5*app.defaultMargins
            color: "white"
            font.pixelSize: app.baseFontSize
            font.bold: true
            font.family: app.mainFontFamily.name
            Layout.minimumWidth: 40 * app.scaleFactor
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            function setText (hour) {
                var txt = ""
                if (hour === 1) {
                    txt = "Detected Last Hour"
                } else {
                    txt = "Detected Last " + hour + " Hours"
                }
                sliderLabel.text = txt
            }
        }

        ImageButton {
            id: menuButton
            width: 38.4 * app.scaleFactor
            height: 38.4 * app.scaleFactor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: app.defaultMargins
            checkedColor : "transparent"
            pressedColor : app.secondaryColor
            hoverColor : "transparent"
            glowColor : "transparent"
            source: app.imgFolder.arg("menu_xxxhdpi.png")

            onClicked: {
                mapPage.defaultView() // First hide other open windows
                if (menuWindow.x == app.width) {
                    menuWindow.x = app.width - menuWindow.width
                    mapShadow.visible = true
                } else {
                    menuWindow.x = app.width
                    mapShadow.visible = false
                }
            }
        }
    }

    Rectangle {
        id: menuWindow

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        width: Math.min(app.width - 60 * scaleFactor, 288 * scaleFactor)
        z: 20
        color: app.secondaryColor
        border.color: app.themeColor
        border.width: 1 * app.scaleFactor
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: false
            color: app.shadowColor
            verticalOffset: 3
            horizontalOffset: 1
            samples: 20
            radius: 10.0
            cached: true
        }

        Button {
            id: notification

            //radius: 5
            //color: app.shadowColor
            width: 0.97 * parent.width
            anchors.margins: app.defaultMargins/2.5
            anchors.horizontalCenter: parent.horizontalCenter
            height: 80 * app.scaleFactor
            style: ButtonStyle {
                background: Rectangle {
                    color: "grey"
                }
            }

            Image {
                id: notificationImg
                source: app.imgFolder.arg("notification_xxxhdpi.png")
                width: 38.4 * app.scaleFactor
                height: 38.4 * app.scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: app.defaultMargins
            }

            Column {
                anchors.left: notificationImg.right
                anchors.margins: app.defaultMargins
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: qsTr("Notifications")
                    color: "white"
                    font.pixelSize: 1.2 * app.baseFontSize
                    font.bold: true
                    font.family: app.mainFontFamily.name
                    Layout.minimumWidth: 40 * app.scaleFactor
                }

                RowLayout {
                    ExclusiveGroup {
                        id: tabPositionGroup
                    }
                    RadioButton {
                        id: onButton
                        exclusiveGroup: tabPositionGroup
                        Layout.minimumWidth: 45 * app.scaleFactor
                        style: RadioButtonStyle {
                            label: Label {
                                text: qsTr("On")
                                color: app.secondaryColor
                                font.pixelSize: 0.8 * app.baseFontSize
                                font.bold: true
                                font.family: app.mainFontFamily.name
                            }
                        }
                    }
                    RadioButton {
                        id: offButton
                        checked: true
                        exclusiveGroup: tabPositionGroup
                        Layout.minimumWidth: 45 * app.scaleFactor
                        style: RadioButtonStyle {
                            label: Label {
                                text: qsTr("Off")
                                color: app.secondaryColor
                                font.pixelSize: 0.8 * app.baseFontSize
                                font.bold: true
                                font.family: app.mainFontFamily.name
                            }
                        }
                    }
                }
            }
        }

        Button {
            id: about

            //radius: 5
            //color: app.shadowColor
            width: 0.97 * parent.width
            anchors.margins: app.defaultMargins/2.5
            anchors.top: notification.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            height: 80 * app.scaleFactor
            style: ButtonStyle {
                background: Rectangle {
                    color: "grey"
                }
            }

            Image {
                id: aboutImg
                source: app.imgFolder.arg("about_xxxhdpi.png")
                width: 38.4 * app.scaleFactor
                height: 38.4 * app.scaleFactor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.margins: app.defaultMargins
            }

            Column {
                anchors.left: aboutImg.right
                anchors.margins: app.defaultMargins
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: qsTr("About")
                    color: "white"
                    font.pixelSize: 1.2 * app.baseFontSize
                    font.bold: true
                    font.family: app.mainFontFamily.name
                    Layout.minimumWidth: 40 * app.scaleFactor
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    aboutPage.visible = true
                }
            }
        }

        x: app.width
        Behavior on x {NumberAnimation { duration: 400; easing.type: Easing.OutQuad }}
    }

    Loader {
        id: aboutPage
        anchors.fill: mapPage
        z: 50
        visible: false
        sourceComponent: Rectangle {
            anchors.fill: parent
            color: app.secondaryColor
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
            }
            Rectangle {
                id: menuHeader
                anchors.top: parent.top
                width: parent.width
                height: 60 * app.scaleFactor
                color: app.themeColor
                z: 30 // keeps the shadow visible
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: false
                    color: app.shadowColor
                    verticalOffset: 4
                    horizontalOffset: 1
                    samples: 20
                    radius: 10.0
                    cached: true
                }

                ImageButton {
                    id: arrowLeft
                    width: 38.4 * app.scaleFactor
                    height: 38.4 * app.scaleFactor
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: app.defaultMargins
                    checkedColor : "transparent"
                    pressedColor : app.secondaryColor
                    hoverColor : "transparent"
                    glowColor : "transparent"
                    source: app.imgFolder.arg("arrow_left_xxxhdpi.png")

                    onClicked: {
                        aboutPage.visible = false
                    }
                }

                Text {
                    text: qsTr("About")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: arrowLeft.right
                    font.pixelSize: 1.2 * app.baseFontSize
                    font.bold: true
                    font.family: app.mainFontFamily.name
                    width: 0.7 * parent.width
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
            }

            Text {
                id: appTitle
                text: "ActiveFires %1".arg(app.info.version)
                width: 0.8 * parent.width
                anchors.top: menuHeader.bottom
                anchors.margins: app.defaultMargins
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: app.mainFontFamily.name
                font.pixelSize: 1.2 * app.baseFontSize
                font.bold: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: app.appLabelColor
            }

            Text {
                text: qsTr("ActiveFires notifies you of forest fires near you, and shows you fires around the globe, all within 60 - 180 minutes of when they are detected by satellite.")
                anchors.top: appTitle.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: app.defaultMargins
                font.family: app.mainFontFamily.name
                font.pixelSize: 1 * app.baseFontSize
                wrapMode: Text.WordWrap
            }

            Text {
                width: 0.99 * parent.width
                text: qsTr("Data Source")
                anchors.margins: app.defaultMargins
                font.family: app.mainFontFamily.name
                font.pixelSize: 0.6 * app.baseFontSize
                font.bold: true
                color: app.appLabelColor
                anchors.bottom: dataSource.top
                anchors.left: parent.left
                wrapMode: Text.WordWrap
            }
            Text {
                id: dataSource
                width: 0.99 * parent.width
                text: qsTr("NASA LANCE ‐ FIRMS, 2012. MODIS Active Fire Detections. Data set.")
                anchors.margins: app.defaultMargins
                font.family: app.mainFontFamily.name
                font.pixelSize: 0.6 * app.baseFontSize
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        id: hourSlider

        z: 10
        color: app.secondaryColor
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width:  parent.width * 0.995
        height: 60 * app.scaleFactor
        border.color: app.themeColor
        border.width: 1 * app.scaleFactor
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: false
            color: app.shadowColor
            verticalOffset: 2
            horizontalOffset: 1
            samples: 20
            radius: 10.0
            cached: true
        }
        transform: Translate {
            id: sliderDisplay
            y: 0
            Behavior on y {NumberAnimation { duration: 400; easing.type: Easing.OutQuad }}
            onYChanged: {
                // Makes sure slider is not clickable when hidden
                y == 0 ? slider.visible = false : slider.visible = true
            }
        }
        Component.onCompleted: slider.visible = false // Makes sure slider is not clickable when hidden

        Slider {
            id: slider
            property int maxValue: 12
            property int initialValue: maxValue

            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: app.defaultMargins * 1.5

            tickmarksEnabled : true
            updateValueWhileDragging : false
            value: initialValue
            maximumValue: maxValue
            minimumValue: 1
            stepSize: 1
            width: 0.8 * parent.width

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                propagateComposedEvents: true
                onClicked: mouse.accepted = false;
                onPressed: mouse.accepted = false;
                onDoubleClicked: mouse.accepted = false;
                onPositionChanged: mouse.accepted = false;
                onPressAndHold: mouse.accepted = false;
                onReleased: mouse.accepted = false;
            }

            style: SliderStyle {
                groove: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: 5 * app.scaleFactor
                    border.color: app.themeColor
                    border.width: 1 * app.scaleFactor
                    LinearGradient {
                        anchors.fill: parent
                        start: Qt.point(0, 0)
                        end: Qt.point(parent.width, 0)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "red" }
                            GradientStop { position: 1.0; color: "yellow" }
                        }
                    }
                    radius: 4 * app.scaleFactor
                }
                handle: Rectangle {
                    anchors.centerIn: parent
                    color: control.pressed ? app.secondaryColor : "white"
                    border.color: app.themeColor
                    border.width: 1 * app.scaleFactor
                    implicitWidth: 15 * app.scaleFactor
                    implicitHeight: 15 * app.scaleFactor
                    radius: 4 * app.scaleFactor
                }
            }

            Text {
                id: leftValueMarker
                anchors.horizontalCenter: parent.left
                anchors.top: parent.bottom
                anchors.topMargin: 0.6 * app.defaultMargins
                font.pixelSize: 14 * app.scaleFactor
                font.bold: true
                text: slider.minimumValue === 1? 1 + " hour" : slider.minimumValue + " hours"
                font.family: app.mainFontFamily.name
                color: app.darkerThemeColor
            }

            Text {
                id: rightValueMarker
                anchors.horizontalCenter: parent.right
                anchors.top: parent.bottom
                anchors.topMargin: 0.6 * app.defaultMargins
                font.pixelSize: 14 * app.scaleFactor
                font.bold: true
                text: slider.maximumValue + " hours"
                font.family: app.mainFontFamily.name
                color: app.darkerThemeColor
            }

            onValueChanged: {
                if (map) {
                    map.updateDisplay(value)
                }
                sliderLabel.setText(value)
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        //running: image.status === Image.Loading
        anchors.centerIn: parent
        z: 40
    }

    Map {
        id: map

        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        wrapAroundEnabled: true
        rotationByPinchingEnabled: false
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true
        extent: Envelope {
            id: mapExtent
            // initial extent
            yMin: -19674050
            yMax: 17306193
            xMin: -19674050
            xMax: 363460
        }

        SpatialReference {
            id: wgs84
            wkid: 4326
        }

        ArcGISTiledMapServiceLayer {
            url: app.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        }

        PictureMarkerSymbol {
            id: fireSymbol
            image: app.imgFolder.arg("fire_12.png")
            width: 9 * app.scaleFactor
            height: 9 *app.scaleFactor
        }

        MultiPoint {
            id: mp
            function removeAllPoints() {
                for(var i=0; i<mp.pointCount; i++) {
                    mp.removePoint(i)
                }
            }
        }

        ModalWindow {
            id: modal
            scaleFactor: app.scaleFactor
            shadowColor: app.shadowColor
            backgroundColor: app.secondaryColor
        }

        DropShadow {
            id: mapShadow

            source: map
            anchors.fill: source
            radius: 8
            samples: 16
            opacity: 0.75
            color: app.shadowColor
            visible: false
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: false
                onWheel: wheel.accepted = true
                onClicked: {
                    defaultView()
                }
            }
        }

        GraphicsLayer {
            id: mainGraphicLayer

            onFindGraphicsComplete  : {

                if (!graphicIDs || graphicIDs.length === 0) {
                    console.log("No Results from graphics layer click")
                    return
                }

                var graphics = [];
                for (var j in graphicIDs) {
                    graphics.push(mainGraphicLayer.graphic(graphicIDs[j]))
                }

                var id = graphicIDs
                console.log("onFindGraphicComplete .... got id => ", id)

                clearSelection()
                modal.dataModel.clear()

                for (var i in graphics) {
                    var feature = graphics[i]
                    var model_data = {"index": i+1}
                    var attr = feature.attributes

                    selectGraphic(feature.uniqueId)
                    model_data["satellite"] = attr.satellite
                    model_data["confidence"] = attr.confidence
                    model_data["acq_datetime"] = attr.acq_datetime
                    model_data["record_age"] = attr.record_age
                    model_data["frp"] = attr.frp
                    model_data["longitude"] = attr.longitude
                    model_data["latitude"] = attr.latitude
                    model_data["img_path"] = "../%1".arg(app.imgFolder.arg("fire_%1.png".arg(attr.record_age)))
                    modal.dataModel.append(model_data)
                }
                mapPage.defaultView() // First hide other open windows
                modal.visible = true
            }
        }

        onMouseClicked: {
            mainGraphicLayer.findGraphics(mouse.x, mouse.y, 10, 10);
        }

        onStatusChanged: {
            if(status === Enums.MapStatusReady) {
                getData(app.dataUrl)
            }
        }

        function getData(currentURL) {
            var request = new XMLHttpRequest()
            request.onreadystatechange = function() {
                if (request.readyState == 4) {
                    var response = request.responseText
                    var json = JSON.parse(request.responseText)
                    addPointsToMap(json.features)
                }
            }
            request.open("GET", currentURL, true)
            request.send()
        }

        function addPointsToMap(data) {

            mainGraphicLayer.removeAllGraphics()
            mp.removeAllPoints()

            var graphic, geom, attr, pt_str="", pt_wgs84
            for (var i=0; i<data.length; i++) {
                pt_str = data[i].geometry.coordinates
                attr = data[i].properties
                graphic = ArcGISRuntime.createObject("Graphic")
                pt_wgs84 = ArcGISRuntime.createObject("Point")
                pt_wgs84.spatialReference = wgs84
                pt_wgs84.x = pt_str[0]
                pt_wgs84.y = pt_str[1]
                graphic.geometry = pt_wgs84.project(map.spatialReference)
                attr["longitude"] = pt_str[0]
                attr["latitude"] = pt_str[1]
                graphic.attributes = attr
                fireSymbol.image = app.imgFolder.arg("fire_%1.png".arg(attr.record_age))
                graphic.symbol = fireSymbol
                mp.add(graphic.geometry)
                mainGraphicLayer.addGraphic(graphic)
            }
            if(mp.pointCount > 1) {
                var extent = mp.queryEnvelope();
                //map.zoomTo(extent.scale(1.2));
            }
            busyIndicator.visible = false
        }

        function updateDisplay(hour) {
            var graphics_list = mainGraphicLayer.graphics
            for (var i=0; i < graphics_list.length; i++) {
                if (graphics_list[i].attributes.record_age > hour && graphics_list[i].visible) {
                    graphics_list[i].visible = false
                } else if (graphics_list[i].attributes.record_age <= hour && !graphics_list[i].visible) {
                    graphics_list[i].visible = true
                }
            }
        }
    }

    // Delaying visibility such that the
    // map and the header are seen at about
    // the same time, since the header tends to
    // be loaded first
    visible: false
    Timer {
        interval: 600; running: true; repeat: false
        onTriggered: mapPage.visible = true
    }
}
