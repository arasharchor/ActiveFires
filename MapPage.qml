import QtQuick 2.3
import QtPositioning 5.3
import QtQuick.Controls 1.4

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0

import "components"


Item {
    id: mapPage

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
            font.pointSize: Math.round(0.40 * parent.height)

            function setText (hour) {
                var txt = ""
                if (hour === 1) {
                    txt = "Fires Detected Last Hour"
                } else {
                    txt = "Fires Detected Last " + hour + " Hours"
                }
                title.text = txt
            }
        }

        ImageButton {
            id: refreshButton
            source: "assets/images/refreshbutton.png"
            width: 40 * app.scaleFactor
            height: 40 * app.scaleFactor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 5

            checkedColor : "transparent"
            pressedColor : "transparent"
            hoverColor : "transparent"
            glowColor : "transparent"

            onClicked: {
                //refresh the data shown
                map.getData(map.dataUrl);
            }
        }
    }

    Map {
        id: map

        property url dataUrl: "http://ljumbam.webfactional.com/ActiveFires.geojson"

        anchors {
            left: parent.left
            right: parent.right
            top: header.bottom
            bottom: footer.top
        }
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true
        extent: Envelope {
            // Initial extent upon load
            yMin: -8479442.640976667
            yMax: 10920490.291989204
            xMin: -25298142.424766235
            xMax: 27138253.607579045
        }

        positionDisplay {
            positionSource: PositionSource {
            }
        }

        ArcGISTiledMapServiceLayer {
            url: app.info.propertyValue("basemapServiceUrl", "http://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer")
        }

        NorthArrow {
            anchors {
                right: parent.right
                top: parent.top
                margins: 10
            }
            visible: map.mapRotation != 0
        }

        ZoomButtons {
            id: zoomButtons
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                margins: 10
            }
            map: map
        }

        SpatialReference {
            id: wgs84
            wkid: 4326
        }

        PictureMarkerSymbol {
            id: fireSymbol
            image: "assets/images/fire32x32.png"
            width: 6
            height: 6
        }

        PictureMarkerSymbol {
            id: recentFireSymbol
            image: "assets/images/recentFire28x40.png"
            width: 6
            height: 9
        }

        ModalWindow {
            id: modal

        }

        GraphicsLayer {
            id: mainGraphicLayer
            //selectionSymbol: fireSymbol

            onFindGraphicsComplete  : {

                if (!graphicIDs || graphicIDs.length === 0) {
                    console.log("No Results from graphics layer click");
                    return;
                }

                var graphics = [];
                for (var j in graphicIDs) {
                    graphics.push(mainGraphicLayer.graphic(graphicIDs[j]));
                }

                var id = graphicIDs;
                console.log("onFindGraphicComplete .... got id => ", id);

                clearSelection();
                modal.dataModel.clear();

                for (var i in graphics) {
                    var feature = graphics[i];
                    var model_data = {"index": i+1}
                    var attr = feature.attributes;

                    selectGraphic(feature.uniqueId);

                    model_data["satellite"] = attr.satellite
                    model_data["confidence"] = attr.confidence
                    model_data["acq_datetime"] = attr.acq_datetime
                    model_data["record_age"] = attr.record_age
                    model_data["frp"] = attr.frp

                    modal.dataModel.append(model_data)
                }
                modal.visible = true;
            }
        }

        Slider {
            id: hourSlider
            property double defaultOpacity: 0.4

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 10
            tickmarksEnabled : true
            updateValueWhileDragging : true
            opacity: defaultOpacity
            value: 12
            maximumValue: 24
            minimumValue: 1
            stepSize: 1
            width: Math.round(0.5*parent.width)

            Text {
                id: leftValueMarker
                anchors.horizontalCenter: parent.left
                anchors.top: parent.bottom
                anchors.topMargin: 5
                font.pointSize: 9
                text: "1 hour"
            }

            Text {
                id: rightValueMarker
                anchors.horizontalCenter: parent.right
                anchors.top: parent.bottom
                anchors.topMargin: 5
                font.pointSize: 9
                text: "24 hours"
            }

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

                onEntered: {
                    parent.opacity = 1.0
                }
                onExited: {
                    parent.opacity = parent.defaultOpacity
                }
            }

            onValueChanged: {
                title.setText(hourSlider.value)
            }

            onPressedChanged: {
                // TODO:
                // - Check if there is an onRelease
                // - Create updateData function for map
                map.getData(map.dataUrl)
                //map.updateData()
            }

        }

        MultiPoint {
            id: mp
            function removeAllPoints() {
                for(var i=0; i<mp.pointCount; i++) {
                    mp.removePoint(i);
                }
            }
        }

        onMouseClicked: {
            mainGraphicLayer.findGraphics(mouse.x, mouse.y, 10, 10);
        }

        onStatusChanged: {
            if(status === Enums.MapStatusReady) {
                getData(map.dataUrl)
            }
        }

        function getData(currentURL) {
            var request = new XMLHttpRequest()
            request.onreadystatechange = function() {
                if (request.readyState == 4) {
                    var response = request.responseText
                    //console.log("!!! Data !!! " + response);
                    var json = JSON.parse(request.responseText);
                    //2. Parse and Add the results to the map
                    addPointsToMap(json);
                }
            }
            request.open("GET", currentURL, true);
            request.send();
        }

        function addPointsToMap(data) {

            mainGraphicLayer.removeAllGraphics();
            mp.removeAllPoints();

            var graphic, geom, attr, pt_str="", pt_wgs84;

            function add(pt, gp) {
                pt_str = pt.geometry.coordinates
                attr = pt.properties
                graphic = ArcGISRuntime.createObject("Graphic");
                pt_wgs84 = ArcGISRuntime.createObject("Point");
                pt_wgs84.spatialReference = wgs84
                pt_wgs84.x = pt_str[0]
                pt_wgs84.y = pt_str[1]

                //TODO: Project the data in python before mapping here
                graphic.geometry = pt_wgs84.project(map.spatialReference);
                graphic.attributes = attr;
                graphic.symbol = gp

                mp.add(graphic.geometry);
                mainGraphicLayer.addGraphic(graphic);
            }

            var recent_fires = [] // Save recent fires and add them after
            // other fires so that they appear at the
            // top of the map. Check later if one can add
            // a z-index to a graphic instead

            for (var i=0; i<data.features.length; i++) {
                var record_age = data.features[i].properties.record_age
                if (record_age === hourSlider.value) {
                    break
                }
                if (record_age < 4) {
                    recent_fires.push(data.features[i])
                } else {
                    add(data.features[i], fireSymbol)
                }
            }

            for (var k=0; k<recent_fires.length; k++) {
                add(recent_fires[k], recentFireSymbol)
            }

            console.log("Total points added: ", mainGraphicLayer.numberOfGraphics);

            if(mp.pointCount > 1) {
                var extent = mp.queryEnvelope();
                zoomButtons.homeExtent = extent.scale(1.2);
                map.zoomTo(extent.scale(1.2));
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
