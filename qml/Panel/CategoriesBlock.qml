import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Categories"

Rectangle {
    id: categoriesTable
    width: parent.width
    height: columns.height + scrollView.height
    color: "transparent"
    Layout.fillWidth: true

    Rectangle {
        id: columns
        width: parent.width
        height: 28
        color: "#201F1F"
        border.width: 1
        border.color: "#2E2D2D"

        CategoriesColumn {
            id: keyColumn
            width: 40
            height: parent.height
            text: qsTr("Key")
        }
        CategoriesColumn {
            id: nameColumn
            width: 120
            height: parent.height
            text: qsTr("Name")
            anchors {left: keyColumn.right;}
        }
        CategoriesColumn {
            id: filesCountColumn
            width: 40
            height: parent.height
            text: qsTr("Files")
            anchors {left: nameColumn.right;}
        }
        CategoriesColumn {
            id: clearButtonColumn
            width: 50
            height: parent.height
            text: qsTr("Clear")
            anchors {left: filesCountColumn.right;}
        }
    }

    Flickable {
        id: scrollView
        width: parent.width
        height: categoriesHeight * 7
        contentWidth: width
        contentHeight: rows.height
        anchors {top: columns.bottom}
        clip: true

        MouseArea {
            anchors.fill: parent
            onClicked: forceActiveFocus()
        }

        Column {
            id: rows
            width: parent.width
            height: childrenRect.height

            Repeater {
                id: repeater
                width: parent.width
                model: categoriesCount
                delegate: CategoriesRow {
                    width: parent.width
                    height: categoriesHeight
                    color: "#201F1F"
                    border.width: 1
                    border.color: "#2E2D2D"
                    outerIndex: index
                }
            }
        }
    }
}
