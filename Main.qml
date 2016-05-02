/* Copyright 2015 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Controls 1.2


import ArcGIS.AppFramework 1.0

//------------------------------------------------------------------------------

App {
    id: app

    property double scaleFactor: AppFramework.displayScaleFactor
    property int deviceWidth: 360
    property int deviceHeight: 640

    property string appName: qsTr("ActiveFires")

    property url dataUrl: "http://ljumbam.webfactional.com/ActiveFires.geojson"

    property color themeColor: "#6D4C41"
    property color secondaryColor: "#EFEBE9"
    property color backgroundColor: secondaryColor
    property color darkerThemeColor: "#3E2723"
    property color baseFontColor: "#FFFFFF"
    property color appLabelColor: "#4c0000"
    property color shadowColor: Qt.rgba(0, 0, 0, 0.3)

    property int baseFontSize: Math.round(20 * scaleFactor)
    property alias mainFontFamily: fontSourceSansProReg

    property string imgFolder: "assets/img/%1"

    property real defaultMargins: 10 * scaleFactor

    width: deviceWidth
    height: deviceHeight

    FontLoader {
        id: fontSourceSansProReg
        source: app.folder.fileUrl("assets/fonts/SourceSansPro-Regular.ttf")
    }

    SplashPage {
        id: splashPage
        anchors.fill: parent
    }

}

//------------------------------------------------------------------------------
