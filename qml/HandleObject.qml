import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: handleObject

    property var filenameText: undefined
    property var fileResolutionText: undefined
    property var fileSizeText: undefined

    property int outerIndex: undefined

    readonly property real fontPointSize: 10

    property alias sourcePhoto: photo.source

    width: parent.width
    height: parent.height
    color: "#444444"
    radius: 5

    Rectangle {
        width: 150
        height: 155
        color: "transparent"
        anchors {
            top: parent.top;
            leftMargin: 2;
            rightMargin: 2;
            left: parent.left;
        }

        Image {
            id: photo
            asynchronous: true
            width: 145
            height: 100
            sourceSize.width: 1024
            sourceSize.height: 512
            fillMode: Image.PreserveAspectFit
            smooth: true
            anchors {centerIn: parent;}
        }

        MouseArea {
            id: rotateLeftArea
            width: 25
            height: 25
            hoverEnabled: true
            anchors {left: parent.left; bottom: parent.bottom; leftMargin: 2; bottomMargin: 2}

            Image {
                id: rotateLeftImage
                anchors.fill: parent
                source: Qt.resolvedUrl("./Assets/RotateLeft138x138@2x.png")
            }

            onEntered: {
                rotateLeftImage.source = Qt.resolvedUrl("./Assets/RotateLeftHover138x138@2x.png")
            }
            onExited: {
                rotateLeftImage.source = Qt.resolvedUrl("./Assets/RotateLeft138x138@2x.png")
            }

            onPressed: {
                if (photo.rotation >= 360 || photo.rotation <= -360) {
                    photo.rotation = 0
                    photo.rotation -= 90
                } else {
                    photo.rotation -= 90
                    if (photo.rotation >= 360 || photo.rotation <= -360) {
                        photo.rotation = 0
                    }
                }
            }
        }

        MouseArea {
            id: rotateRightArea
            width: 25
            height: 25
            hoverEnabled: true
            anchors {right: parent.right; bottom: parent.bottom; rightMargin: 2; bottomMargin: 2}

            Image {
                id: rotateRightImage
                anchors.fill: parent
                source: Qt.resolvedUrl("./Assets/RotateRight138x138@2x.png")
            }

            onEntered: {
                rotateRightImage.source = Qt.resolvedUrl("./Assets/RotateRightHover138x138@2x.png")
            }
            onExited: {
                rotateRightImage.source = Qt.resolvedUrl("./Assets/RotateRight138x138@2x.png")
            }

            onPressed: {
                if (photo.rotation >= 360 || photo.rotation <= -360) {
                    photo.rotation = 0
                    photo.rotation += 90
                } else {
                    photo.rotation += 90
                    if (photo.rotation >= 360 || photo.rotation <= -360) {
                        photo.rotation = 0
                    }
                }
            }
        }
    }

    Rectangle {
        id: categories
        width: (categoriesModelData !== undefined ? (categoriesModelData.count > 0 ? categoriesListWidth - 5 : 0) : 0)
        height: parent.height
        color: "transparent"
        anchors {top: parent.top; bottom: parent.bottom; right: parent.right}
        visible: (categoriesModelData !== undefined ? (categoriesModelData.count > 0 ? true : false) : false)

        ListView {
            id: categoriesListView
            width: parent.width
            height: parent.height - 20
            anchors {top: parent.top; bottom: parent.bottom; left: parent.left; right: parent.right; centerIn: parent;}
            model: categoriesModel
            spacing: 5
            clip: true

            ScrollBar.vertical: ScrollBar {
                id: categoriesVerticalBar
                width: 10
                interactive: true
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                anchors {top: parent.top; right: parent.right; bottom: parent.bottom}
                policy: ScrollBar.AsNeeded
                snapMode: ScrollBar.SnapOnRelease
                visible: true

                onActiveChanged: {
                    function delay(delayTime,cb) {
                        timer.interval = delayTime;
                        timer.repeat = false;
                        timer.triggered.connect(cb);
                        timer.start();
                    }
                    if (!categoriesListView.moving && !categoriesVerticalBar.active) {
                        delay(delayTimeMs, function() {
                            if (!categoriesListView.moving && !categoriesVerticalBar.active) {
                                categoriesVerticalBar.visible = false;
                            }
                        })
                    } else {
                        categoriesVerticalBar.visible = true;
                    }
                }
            }

            delegate: Rectangle {
                id: categoriesItem

                property var modelData: model

                x: (categoriesListView.width - width) / 2
                width: categoriesListView.width - 20
                height: 15
                color: "#363636"
                radius: 5

                MouseArea {
                    anchors.fill: categoriesItem

                    onClicked: {
                        if (categoriesItem.color == "#363636") {
                            categoriesItem.color = "#3B99FC"

                            model.count = model.count + 1

                            model.photos.append({"photo_index": outerIndex, "photo_path": photo.source.toString(), "rotation": photo.rotation})
                        } else {
                            categoriesItem.color = "#363636"

                            model.count = model.count - 1

                            for (var i = 0; i < model.photos.count; i++) {
                                var data = model.photos.get(i)
                                if (data.photo_index === outerIndex) {
                                    model.photos.remove(i)
                                }
                            }
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: modelData.name
                    color: "white"
                    font.pointSize: 11
                    font.family: "Helvetica"
                    leftPadding: 2
                    elide: Text.ElideMiddle
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.centerIn: parent
                }
            }
        }
    }

    Rectangle {
        id: photoDetails

        width: parent.width - categories.width
        height: totalHeightTextFields
        color: "transparent"
        anchors {bottomMargin: 4; bottom: parent.bottom}

        ColumnLayout {
            width: parent.width
            height: parent.height
            spacing: 1
            anchors.fill: parent

            Label {
                id: filename
                width: parent.width
                height: filenameChecked !== false ? textAreaHeight : 0
                color: "#878787"
                text: filenameChecked !== false ? filenameText : ""
                font.pointSize: fontPointSize
                font.family: "Helvetica"
                font.weight: Font.DemiBold
                style: Text.Raised
                elide: Text.ElideMiddle
                visible: filenameChecked !== false ? 1 : 0
                leftPadding: 8
                rightPadding: leftPadding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
            }

            Label {
                id: fileResolution
                width: parent.width
                height: fileResolutionChecked !== false ? textAreaHeight : 0
                color: "#878787"
                text: fileResolutionChecked !== false ? fileResolutionText : ""
                font.pointSize: fontPointSize
                font.family: "Helvetica"
                font.weight: Font.DemiBold
                style: Text.Raised
                elide: Text.ElideMiddle
                visible: fileResolutionChecked !== false ? 1 : 0
                leftPadding: 8
                rightPadding: leftPadding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
            }

            Label {
                id: fileSize
                width: parent.width
                height: fileSizeChecked !== false ? textAreaHeight : 0
                color: "#878787"
                text: fileSizeChecked !== false ? fileSizeText : ""
                font.pointSize: fontPointSize
                font.family: "Helvetica"
                font.weight: Font.DemiBold
                style: Text.Raised
                elide: Text.ElideMiddle
                visible: fileSizeChecked !== false ? 1 : 0
                leftPadding: 8
                rightPadding: leftPadding
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
            }
        }
    }
}
