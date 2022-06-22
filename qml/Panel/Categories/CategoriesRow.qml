import QtQuick
import QtQuick.Controls

Rectangle {

    property int outerIndex: undefined
    property alias filesCount: filesCountRow.text

    Text {
        id: keyRow
        width: keyColumn.width
        height: parent.height
        color: "white"
        text: {
            if (parent.outerIndex !== undefined) {
                return parent.outerIndex
            }
        }
        font.pointSize: 11
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors {verticalCenter: parent.verticalCenter;}
    }

    TextField {
        id: nameCategoryRow
        width: nameColumn.width
        height: parent.height
        placeholderTextColor: "#747374"
        placeholderText: qsTr("New Category")
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors {left: keyRow.right; verticalCenter: parent.verticalCenter;}
        focusReason: {Qt.OtherFocusReason}
        background: Rectangle {
            width: parent.width
            height: parent.height
            color: "transparent"
            border.width: 3
            border.color: nameCategoryRow.activeFocus ? "#1D648E" : "transparent"
        }
        onEditingFinished: {
            if (text.length > 0) {
                categoryAdded(keyRow.text, text)
            }
            if (text.length === 0) {
                categoryRemoved(keyRow.text)
            }
        }
    }

    Text {
        id: filesCountRow
        width: filesCountColumn.width
        height: parent.height
        color: "white"
        text: {
            if ((categoriesModel !== undefined) && (categoriesModel.count !== 0)) {
                for (var i = 0; i < categoriesModel.count; i++) {
                    var data = categoriesModel.get(i)
                    if (data.categoryIndex == outerIndex) {
                        return data.count
                    }
                }
            }
            return 0
        }
        font.pointSize: 11
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        anchors {left: nameCategoryRow.right; verticalCenter: parent.verticalCenter;}
    }

    Button {
        id: clearButton
        width: 25
        height: 25
        icon.width: width - 8
        icon.height: height - 8
        icon.source: {
            if (hovered && nameCategoryRow.length > 0) {
                return Qt.resolvedUrl("../../Assets/ClearHover16x16@2x.png")
            }
            if (nameCategoryRow.length === 0) {
                return Qt.resolvedUrl("../../Assets/ClearAlternate16x16@2x.png")
            }
            if (nameCategoryRow.length > 0) {
                return Qt.resolvedUrl("../../Assets/Clear16x16@2x.png")
            }
        }
        anchors {left: filesCountRow.right; leftMargin: (clearButtonColumn.width - width) / 2; verticalCenter: parent.verticalCenter;}
        background: Rectangle {
            width: parent.icon.width
            height: parent.icon.height
            color: "#2A292A"
            border.color: "transparent"
            border.width: 0
            anchors.centerIn: clearButton
        }
        onClicked: {
            forceActiveFocus()
            nameCategoryRow.text = ""
            categoryRemoved(keyRow.text)
        }
    }
}
