import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
    id: window

    width: 1200
    height: 900
    minimumWidth: 880
    minimumHeight: 708

    palette.windowText: "#787778"
    palette.highlight: "white"
    palette.button: "#787778"
    palette.window: "#323232"
    palette.base: "#323232"
    palette.text: "white"
    palette.mid: "#323232"
    visible: true
    title: "Genesis"

    MouseArea {
        anchors.fill: parent
        onClicked: forceActiveFocus()
    }

    Rectangle {
        id: root

        width: parent.width
        height: parent.height
        color: "#2E2D2D"

        Rectangle {
            id: head

            width: parent.width
            height: 55
            color: "#1A1A1A"
            anchors.top: parent.top

            Rectangle {
                width: childrenRect.width
                height: 12
                anchors {left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter;}
                color: "transparent"

                CheckBox {
                    id: filenameCheckBox

                    signal filenameCheckChanged(bool checked)

                    height: parent.height
                    text: qsTr("Filename")
                    onCheckedChanged: {
                        filenameCheckChanged(checked)
                    }
                }

                CheckBox {
                    id: resolutionCheckBox

                    signal fileResolutionCheckChanged(bool checked)

                    height: parent.height
                    anchors {left: filenameCheckBox.right; leftMargin: 10}
                    text: qsTr("Resolution")
                    onCheckedChanged: {
                        fileResolutionCheckChanged(checked)
                    }
                }

                CheckBox {
                    id: sizeCheckBox

                    signal fileSizeCheckChanged(bool checked)

                    height: parent.height
                    anchors {left: resolutionCheckBox.right; leftMargin: 10}
                    text: qsTr("Size")
                    onCheckedChanged: {
                        fileSizeCheckChanged(checked)
                    }
                }
            }

            Rectangle {
                id: logo
                width: 180
                height: parent.height
                color: "transparent"
                anchors.right: parent.right
                Image {
                    width: 120
                    height: 26
                    anchors.centerIn: parent
                    source: Qt.resolvedUrl("./Assets/Logo600x126@2x.png")
                }
            }
        }

        ListModel {
            id: categoriesModel
        }

        MainScreen {
            id: mScreen
            width: root.width - rightPanel.width > 400 ? root.width - rightPanel.width : 400
            height: root.height - head.height
            color: root.color
            anchors.bottom: parent.bottom
            categoriesModelData: categoriesModel
        }

        RightPanel {
            id: rightPanel
            width: 250
            height: root.height - head.height
            color: root.color
            anchors {left: mScreen.right; top: head.bottom;}
            categoriesModelData: categoriesModel
        }
    }

    Connections {
        target: rightPanel
        ignoreUnknownSignals: true

        function onSourceFolderSelected(modelFileName, modelFilePath, modelFileSize, modelFileResolution) {
            mScreen.visible = false
            mScreen.modelFileName = undefined
            mScreen.modelFilePath = undefined
            mScreen.modelFileSize = undefined
            mScreen.modelFileResolution = undefined

            mScreen.modelFileName = modelFileName
            mScreen.modelFilePath = modelFilePath
            mScreen.modelFileSize = modelFileSize
            mScreen.modelFileResolution = modelFileResolution
            mScreen.visible = true
        }

        function createNewList() {
            var newListModel = Qt.createQmlObject('import QtQuick 2.2; \
                ListModel {}', categoriesModel);
            return newListModel;
        }

        function onCategoryAdded(categoryIndex, categoryName) {
            var exists = false

            for (var i = 0; i < categoriesModel.count; i++) {
                var data = categoriesModel.get(i)
                if (data.categoryIndex === categoryIndex) {
                    exists = true
                    categoriesModel.set(i, {categoryIndex: categoryIndex, "name": categoryName, "count": data.count, "photos": data.photos})
                }
            }

            if (!exists) {
                categoriesModel.append({categoryIndex: categoryIndex, "name": categoryName, "count": 0, "photos": createNewList()})
            }
        }

        function onCategoryRemoved(categoryIndex) {
            for (var i = 0; i < categoriesModel.count; i++) {
                var data = categoriesModel.get(i)
                if (data.categoryIndex === categoryIndex) {
                    for (var j = 0; j < data.photos.count; j++) {
                        data.photos.remove(j)
                    }
                    data.photos.clear()
                    delete data.photos

                    categoriesModel.remove(i)
                    gc()
                }
            }
        }

        function onSaveData(targetFolder) {
            if (targetFolder !== undefined) {
                Qt.createQmlObject('import QtQuick; \
                    import QtQuick.Controls; \
                    Dialog { \
                        title: "Work is start"; \
                        width: 300; \
                        height: 100; \
                        anchors.centerIn: parent; \
                        standardButtons: Dialog.Ok; \
                        contentItem: Text { \
                            width: parent.width; \
                            height: 20; \
                            text: "Please wait! You will get notification."; \
                            elide: Text.ElideMiddle; \
                            color: "white"; \
                            horizontalAlignment: Text.AlignHCenter; \
                        } \
                        Component.onCompleted: { \
                            open(); \
                        } \
                    }', root)
                var status = Gensort.export_data(categoriesModel, targetFolder)
                if (status === true) {
                    Qt.createQmlObject('import QtQuick; \
                        import QtQuick.Controls; \
                        Dialog { \
                            title: "Complete"; \
                            width: 300; \
                            height: 100; \
                            anchors.centerIn: parent; \
                            standardButtons: Dialog.Ok; \
                            contentItem: Text { \
                                width: parent.width; \
                                height: 20; \
                                text: "Congratulations! Work is done."; \
                                elide: Text.ElideMiddle; \
                                color: "white"; \
                                horizontalAlignment: Text.AlignHCenter; \
                            } \
                            Component.onCompleted: { \
                                open(); \
                            } \
                        }', root)
                } else {
                    Qt.createQmlObject('import QtQuick; \
                        import QtQuick.Controls; \
                        Dialog { \
                            title: "Something bad"; \
                            width: 300; \
                            height: 100; \
                            anchors.centerIn: parent; \
                            standardButtons: Dialog.Ok; \
                            contentItem: Text { \
                                width: parent.width; \
                                height: 20; \
                                text: "Unknown Error."; \
                                elide: Text.ElideMiddle; \
                                color: "white"; \
                                horizontalAlignment: Text.AlignHCenter; \
                            } \
                            Component.onCompleted: { \
                                open(); \
                            } \
                        }', root)
                }
            } else {
                Qt.createQmlObject('import QtQuick; \
                    import QtQuick.Controls; \
                    Dialog { \
                        title: "Wait a moment"; \
                        width: 300; \
                        height: 100; \
                        anchors.centerIn: parent; \
                        standardButtons: Dialog.Ok; \
                        contentItem: Text { \
                            width: parent.width; \
                            height: 20; \
                            text: "Please select target folder."; \
                            elide: Text.ElideMiddle; \
                            color: "white"; \
                            horizontalAlignment: Text.AlignHCenter; \
                        } \
                        Component.onCompleted: { \
                            open(); \
                        } \
                    }', root)
            }
        }
    }

    Connections {
        target: filenameCheckBox
        ignoreUnknownSignals: true

        function onFilenameCheckChanged(checked) {
            mScreen.filenameChecked = checked
        }
    }

    Connections {
        target: resolutionCheckBox
        ignoreUnknownSignals: true

        function onFileResolutionCheckChanged(checked) {
            mScreen.fileResolutionChecked = checked
        }
    }

    Connections {
        target: sizeCheckBox
        ignoreUnknownSignals: true

        function onFileSizeCheckChanged(checked) {
            mScreen.fileSizeChecked = checked
        }
    }
}

