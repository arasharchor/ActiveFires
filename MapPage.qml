import QtQuick 2.3
import QtQuick.Controls 1.2
import QtPositioning 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import ArcGIS.AppFramework.Runtime 1.0
import ArcGIS.AppFramework.Runtime.Controls 1.0


Item {
    id: mapPage

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
    }

    Map {
        id: map
        anchors {
            left: parent.left
            right: parent.right
            top: headerItem.bottom
            bottom: footerItem.top
        }
        wrapAroundEnabled: true
        rotationByPinchingEnabled: true
        magnifierOnPressAndHoldEnabled: true
        mapPanningByMagnifierEnabled: true
        zoomByPinchingEnabled: true

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
            id: highlightSymbol
            image: "assets/images/fire10x10.png"
            width: 7
            height: 7

        }

        GraphicsLayer {
            id: mainGraphicLayer
            selectionSymbol: highlightSymbol

            /*
            onFindGraphicsComplete  : {

                if(!graphicIDs || graphicIDs.length === 0) {
                    console.log("No Results from graphics layer click");
                    return;
                }

                var graphics = [];
                for(var j in graphicIDs) {
                    graphics.push(mainGraphicLayer.graphic(graphicIDs[j]));
                }

                var id = graphicIDs;
                console.log("onFindGraphicComplete .... got id => ", id);

                clearSelection();
                modal.dataModel.clear();

                for (var i in graphics) {
                    var feature = graphics[i];
                    var attr = feature.attributes;
                    selectGraphic(feature.uniqueId);
                    //console.log(JSON.stringify(feature.attributes));
                    modal.dataModel.append({"index": i+1, "description": attr.title + "<br><br>" + attr.type + " of magnitude " + attr.mag + ". More details here: <a href='" + attr.url + "'>" + attr.url + "</a><br><br>" + new Date(attr.time).toLocaleString()})
                }
                modal.visible = true;

            }*/

        }

        MultiPoint {
            id: mp
            function removeAllPoints() {
                for(var i=0; i<mp.pointCount; i++) {
                    mp.removePoint(i);
                }
            }
        }

        onStatusChanged: {
            if(status === Enums.MapStatusReady) {
                //getData("http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/significant_week.geojson")
                getData("http://www.africansayings.com/site_media/static/LatestFires.json")
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

            var graphic, geom, /*attr,*/ pt_str="", pt_wgs84;

            mainGraphicLayer.removeAllGraphics();
            mp.removeAllPoints();

            for (var i=0; i<data.length; i++) {
                pt_str = [data[i].longitude, data[i].latitude]
                graphic = ArcGISRuntime.createObject("Graphic");
                pt_wgs84 = ArcGISRuntime.createObject("Point");
                pt_wgs84.spatialReference = wgs84
                pt_wgs84.x = pt_str[0]
                pt_wgs84.y = pt_str[1]

                graphic.geometry = pt_wgs84.project(map.spatialReference);
                //graphic.attributes = attr;
                graphic.symbol = highlightSymbol
                //console.log(JSON.stringify(graphic.json));
                mp.add(graphic.geometry);
                mainGraphicLayer.addGraphic(graphic);
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
