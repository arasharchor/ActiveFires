import QtQuick 2.3
import ArcGIS.AppFramework 1.0

Item {

    function scale(num) {
        return AppFramework.displayScaleFactor * num
    }

    property alias mainFontFamily: fontSourceSansProReg

    property color themeColor: "#6D4C41"
    property color secondaryColor: "#EFEBE9"
    property color backgroundColor: secondaryColor
    property color darkerThemeColor: "#3E2723"
    property color baseFontColor: "#FFFFFF"
    property color appLabelColor: "#4c0000"
    property color shadowColor: Qt.rgba(0, 0, 0, 0.3)

    property int deviceWidth: 360
    property int deviceHeight: 640
    property int baseFontSize: Math.round(scale(20))

    property real defaultMargins: scale(10)

    property string appName: "ActiveFires"
    property string imgFolder: "assets/img/%1"

    property url dataUrl: "http://ljumbam.webfactional.com/ActiveFires.geojson"

    FontLoader {
        id: fontSourceSansProReg
        source: app.folder.fileUrl("assets/fonts/SourceSansPro-Regular.ttf")
    }
}
