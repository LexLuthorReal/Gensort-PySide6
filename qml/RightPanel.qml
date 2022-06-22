import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Panel"

Rectangle {
    id: root

    property QtObject categoriesModelData: undefined
    
    property int categoriesCount: undefined

    property int fontPointSize: 16
    property string textColor: "#6D6B6C"

    property int textBlockHeight: 40

    property int categoriesHeight: 28

    property int blockNamePadding: 20

    property var sourceFolderName: undefined
    property var sourceFolderPath: undefined

    property var destinationFolderName: undefined
    property var destinationFolderPath: undefined

    signal categoryAdded(variant categoryIndex, variant categoryName)
    signal categoryRemoved(variant categoryIndex)

    signal saveData(variant targetFolder)

    signal sourceFolderSelected(variant modelFileName, variant modelFilePath, variant modelFileSize, variant modelFileResolution)

    width: parent.width
    height: parent.height

    ColumnLayout {
        width: parent.width
        spacing: 10
        anchors {topMargin: spacing; fill: parent}

        Text {
            id: sourcePathText
            width: parent.width
            height: textBlockHeight
            color: textColor
            text: qsTr("SOURCE PATH")
            verticalAlignment: Text.AlignVCenter
            leftPadding: blockNamePadding
            font.pointSize: fontPointSize
            Layout.fillWidth: true
        }

        SourceBlock {
            id: sourceBlock
            width: parent.width
            height: 68
            Layout.fillWidth: true
        }

        Text {
            id: categoriesText
            width: parent.width
            height: textBlockHeight
            color: textColor
            text: qsTr("CATEGORIES")
            verticalAlignment: Text.AlignVCenter
            leftPadding: blockNamePadding;
            font.pointSize: fontPointSize
            Layout.fillWidth: true
        }

        CategoriesBlock {
            id: categoriesBlock
            Layout.fillWidth: true
        }

        Text {
            id: destinationText
            width: parent.width
            height: textBlockHeight
            color: textColor
            text: qsTr("DESTINATION PATH")
            verticalAlignment: Text.AlignVCenter
            leftPadding: blockNamePadding;
            font.pointSize: fontPointSize
            Layout.fillWidth: true
        }

        DestinationBlock {
            id: destinationBlock
            width: parent.width
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
    Component.onCompleted: {
        categoriesCount = Gensort.categories_count
    }
}
