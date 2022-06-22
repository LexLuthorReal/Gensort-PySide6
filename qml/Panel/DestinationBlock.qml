import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.platform

Rectangle {
    id: destinationOptions
    width: parent.width
    height: parent.height - (destinationText.y + destinationText.height)
    color: "#201F1F"
    border.width: 1
    border.color: "#2E2D2D"

    Rectangle {
        id: destinationArea
        width: parent.width - 20
        height: parent.height
        color: "transparent"
        anchors {horizontalCenter: parent.horizontalCenter;}

        Rectangle {
            id: topArea
            width: parent.width
            height: 68
            color: "transparent"
            anchors.top: parent.top

            Rectangle {
                id: selectDestinationFolder
                width: parent.width
                height: parent.height / 2
                color: "transparent"

                Button {
                    id: selectDestinationFolderButton
                    width: 35
                    height: 25
                    icon.width: width
                    icon.height: height
                    icon.source: {
                        if (!hovered) {
                            return Qt.resolvedUrl("../Assets/Folder126x93@2x.png")
                        }
                        if (hovered) {
                            return Qt.resolvedUrl("../Assets/FolderHover126x93@2x.png")
                        }
                    }
                    anchors {top: parent.top; topMargin: 10;}
                    background: Rectangle {
                        width: parent.icon.width
                        height: parent.icon.height
                        color: "transparent"
                        anchors.centerIn: selectDestinationFolderButton
                    }
                    onClicked: {
                        destinationFolderDialog.open()
                    }

                    FolderDialog {
                        id: destinationFolderDialog
                        title: "Please choose a destination folder"
                        folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
                        onAccepted: {
                            destinationFolderName = (String(folder).slice(String(folder).lastIndexOf("/") + 1))
                            destinationFolderPath = currentFolder
                            folder = StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
                        }
                        onRejected: {
                            destinationFolderName = undefined
                            destinationFolderPath = undefined
                        }
                    }
                }
                Text {
                    id: destinationFolderNameText
                    width: parent.width - selectDestinationFolderButton.width
                    text: destinationFolderName !== undefined ? destinationFolderName : qsTr("...")
                    color: destinationFolderName !== undefined ? "white" : "#7B7A7A"
                    bottomPadding: 5
                    anchors {left: selectDestinationFolderButton.right; bottom: selectDestinationFolderButton.bottom}
                }
            }

            Rectangle {
                id: sameAsSourceArea
                width: parent.width
                height: parent.height - selectDestinationFolderButton.height
                color: "transparent"
                anchors {top: selectDestinationFolder.bottom;}
                CheckBox {
                    id: sameAsSourceCheckBox
                    text: qsTr("Same as Source")
                    leftPadding: (selectDestinationFolderButton.width - indicator.width) / 2
                    onCheckedChanged: {
                        if (checked) {
                            destinationFolderName = sourceFolderName
                            destinationFolderPath = sourceFolderPath
                        } else {
                            destinationFolderName = undefined
                            destinationFolderPath = undefined
                        }
                    }
                }
            }
        }

        Rectangle {
            id: bottomArea
            width: parent.width
            height: removeSourceFileCheckBox.height + runButton.height
            color: "transparent"
            anchors.bottom: parent.bottom
            CheckBox {
                id: removeSourceFileCheckBox
                height: 25
                text: qsTr("Remove source file")
                anchors {bottomMargin: 5; bottom: runButton.top; horizontalCenter: parent.horizontalCenter}
            }
            Button {
                id: runButton
                width: 135
                height: 25
                text: qsTr("Run")
                anchors {bottomMargin: 20; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter}
                onClicked: saveData(destinationFolderPath)
            }
        }
    }
}
