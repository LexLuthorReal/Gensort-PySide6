import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {

    id: root

    property QtObject categoriesModelData: undefined

    property bool filenameChecked: false
    property bool fileResolutionChecked: false
    property bool fileSizeChecked: false

    readonly property int textAreaHeight: 18
    property int totalHeightTextFields: (filenameChecked == true ? textAreaHeight : 0) + (fileResolutionChecked  == true ? textAreaHeight : 0) + (fileSizeChecked  == true ? textAreaHeight : 0)

    property var modelFileName: undefined
    property var modelFilePath: undefined
    property var modelFileSize: undefined
    property var modelFileResolution: undefined

    property int delayTimeMs: 5000

    readonly property int elementWidth: 155 + (categoriesModelData !== undefined ? (categoriesModelData.count > 0 ? categoriesListWidth : 0) : 0)
    readonly property int elementHeight: 161 + totalHeightTextFields

    readonly property int categoriesListWidth: 114

    readonly property alias currentRowCount: gridElements.rows
    readonly property alias currentColumnsCount: gridElements.columns
    readonly property int rowSpacingBase: 18
    readonly property int columnSpacingBase: 10
    readonly property alias columnSpacingCurrent: gridElements.columnSpacing
    readonly property int columnsWidth: (elementWidth + columnSpacingBase) * gridElements.columns
    readonly property int marginsContentGridLayout: gridElements.anchors.leftMargin + gridElements.anchors.rightMargin

    signal fileCategorySelected(variant index)
    signal fileCategoryDeselected(variant index)

    Timer {
        id: timer
    }

    width: parent.width
    height: parent.height

    Flickable {

        id: scrollView

        MouseArea {
            anchors.fill: parent
            onClicked: forceActiveFocus()
        }

        interactive: true
        width: parent.width
        height: parent.height
        contentWidth: width - marginsContentGridLayout
        contentHeight: ((currentRowCount * (elementHeight + rowSpacingBase)) + gridElements.anchors.bottomMargin)
        anchors.fill: parent
        clip: true

        ScrollBar.vertical: ScrollBar {
            id: verticalBar
            interactive: true
            hoverEnabled: true
            active: hovered || pressed
            orientation: Qt.Vertical
            anchors {top: parent.top; right: parent.right; bottom: parent.bottom}
            policy: ScrollBar.AsNeeded
            snapMode: ScrollBar.SnapOnRelease
            visible: false

            onActiveChanged: {
                function delay(delayTime,cb) {
                    timer.interval = delayTime;
                    timer.repeat = false;
                    timer.triggered.connect(cb);
                    timer.start();
                }
                if (!scrollView.moving && !verticalBar.active) {
                    delay(delayTimeMs, function() {
                        if (!scrollView.moving && !verticalBar.active) {
                            verticalBar.visible = false;
                        }
                    })
                } else {
                    verticalBar.visible = true;
                }
            }
        }

        GridLayout {

            id: gridElements

            columns: repeater.count > 0 ? Math.max(Math.floor(width / (elementWidth + columnSpacingBase)), 1) : 0
            rows: repeater.count > 0 ? Math.max(Math.ceil(repeater.count / columns), 1) : 0
            rowSpacing: rowSpacingBase
            flow: GridLayout.LeftToRight
            layoutDirection: Qt.LeftToRight
            columnSpacing: ((width - columnsWidth) / columns) + columnSpacingBase
            anchors {leftMargin: 20; rightMargin: 5; topMargin: 20; bottomMargin: 20; fill: parent}

            Repeater {
                id: repeater
                model: modelFileName !== undefined && modelFilePath !== undefined ? modelFileName.length || modelFilePath.length : 0
                HandleObject {
                    id: handleItem
                    width: elementWidth
                    height: elementHeight
                    sourcePhoto: modelFilePath !== undefined ? modelFilePath[index] : undefined
                    filenameText: filenameChecked !== false ? (modelFileName !== undefined ? modelFileName[index] : "") : ""
                    fileSizeText: fileSizeChecked !== false ? (modelFileSize !== undefined ? modelFileSize[index] : "") : ""
                    fileResolutionText: fileResolutionChecked !== false ? (modelFileResolution !== undefined ? modelFileResolution[index] : "") : ""
                    outerIndex: index
                    Layout.minimumWidth: elementWidth
                    Layout.minimumHeight: elementHeight
                    Layout.maximumWidth: elementWidth
                    Layout.maximumHeight: elementHeight
                    Layout.alignment : Qt.AlignCenter
                    PropertyAnimation {
                        target: handleItem
                        property: "scale"
                        from: 0.0
                        to: 1.0
                        duration: 450
                        running: true
                        loops: 1
                    }
                    PropertyAnimation {
                        target: handleItem
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 450
                        running: true
                        loops: 1
                    }
                }
            }
        }

        onMovingChanged: {
            function delay(delayTime,cb) {
                timer.interval = delayTime;
                timer.repeat = false;
                timer.triggered.connect(cb);
                timer.start();
            }
            if (!scrollView.moving && !verticalBar.active) {
                delay(delayTimeMs, function() {
                    if (!scrollView.moving && !verticalBar.active) {
                        verticalBar.visible = false;
                    }
                })
            } else {
                verticalBar.visible = true;
            }
        }
    }
}
