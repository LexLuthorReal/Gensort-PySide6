import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.platform

Rectangle {
    id: sourcePathOptions
    width: parent.width
    height: parent.height
    color: "#201F1F"
    border.width: 1
    border.color: "#2E2D2D"

    Rectangle {
        width: parent.width - 20
        height: parent.height
        color: "transparent"
        anchors {horizontalCenter: parent.horizontalCenter;}

        Rectangle {
            id: folderSelectorArea
            width: parent.width
            height: parent.height / 2
            color: "transparent"

            Button {
                id: selectSourceFolderButton
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
                anchors {bottom: parent.bottom;}
                background: Rectangle {
                    width: parent.icon.width
                    height: parent.icon.height
                    color: "transparent"
                    anchors.centerIn: selectSourceFolderButton
                }
                onClicked: {
                    sourceFolderDialog.open()
                }

                FolderDialog {
                    id: sourceFolderDialog
                    title: "Please choose a source folder"
                    folder: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
                    onAccepted: {
                        var currentfolder_data = Gensort.photos_from_folder(currentFolder, includeSubfolderCheckBox.checked)

                        sourceFolderName = (String(currentFolder).slice(String(currentFolder).lastIndexOf("/") + 1))
                        sourceFolderPath = currentFolder
                        sourceFolderSelected(currentfolder_data[0], currentfolder_data[1], currentfolder_data[2], currentfolder_data[3])

                        folder = StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
                    }
                    onRejected: {
                        if (sourceFolderName !== undefined || sourceFolderPath !== undefined) {
                            sourceFolderName = sourceFolderName
                            sourceFolderPath = sourceFolderPath
                        } else {
                            sourceFolderName = undefined
                            sourceFolderPath = undefined
                        }

                    }
                }
            }
            Text {
                id: sourceFolderNameText
                width: parent.width - selectSourceFolderButton.width
                text: sourceFolderName !== undefined ? sourceFolderName : qsTr("...")
                color: sourceFolderName !== undefined ? "white" : "#7B7A7A"
                bottomPadding: 5
                anchors {left: selectSourceFolderButton.right; bottom: selectSourceFolderButton.bottom}
            }
        }

        Rectangle {
            id: includeSubfolderArea
            width: parent.width
            height: parent.height - folderSelectorArea.height
            color: "transparent"
            anchors {top: folderSelectorArea.bottom;}
            CheckBox {
                id: includeSubfolderCheckBox
                text: qsTr("Include Subfolders")
                leftPadding: (selectSourceFolderButton.width - indicator.width) / 2
            }
        }
    }
}
