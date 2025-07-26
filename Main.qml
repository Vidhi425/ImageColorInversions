import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs
import App 1.0

ApplicationWindow {
    id: window
    width: 800
    height: 600
    visible: true
    title: "Image Color Inverter"

    // ImageProcessor instance
    ImageProcessor {
        id: imageProcessor

        onImagesLoaded: {
            console.log("Images loaded signal received")
            var paths = imageProcessor.getInvertedImagePaths()
            console.log("Number of paths:", paths.length)
            previewGrid.model = paths
            statusText.text = "Images loaded and inverted successfully! (" + paths.length + " images)"
            statusText.color = "green"
            saveButton.enabled = true
        }
    }

    // File dialog for opening images
    FileDialog {
        id: fileDialog
        title: "Select images to invert"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Image files (*.png *.xpm *.jpg *.jpeg *.bmp *.gif)"]

        onAccepted: {
            console.log("Files selected:", selectedFiles.length)
            for (var i = 0; i < selectedFiles.length; i++) {
                console.log("File", i, ":", selectedFiles[i])
            }
            statusText.text = "Processing " + selectedFiles.length + " images..."
            statusText.color = "blue"
            saveButton.enabled = false
            imageProcessor.processImages(selectedFiles.map(url => url.toString()))
        }

        onRejected: {
            console.log("File dialog cancelled")
        }
    }

    // Folder dialog for saving
    FolderDialog {
        id: folderDialog
        title: "Select folder to save inverted images"

        onAccepted: {
            imageProcessor.saveInvertedImages(selectedFolder.toString())
            statusText.text = "Images saved successfully!"
            statusText.color = "green"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header
        Text {
            text: "Image Color Inverter"
            font.pixelSize: 24
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Control buttons
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Button {
                id: openButton
                text: "Open Images"
                font.pixelSize: 14
                implicitHeight: 40
                implicitWidth: 120

                onClicked: {
                    fileDialog.open()
                }
            }

            Button {
                id: saveButton
                text: "Save Inverted Images"
                font.pixelSize: 14
                implicitHeight: 40
                implicitWidth: 150
                enabled: false

                onClicked: {
                    folderDialog.open()
                }
            }
        }


        Text {
            id: statusText
            text: "Click 'Open Images' to start"
            font.pixelSize: 12
            Layout.alignment: Qt.AlignHCenter
            color: "gray"
        }

        // Preview area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: "#cccccc"
            border.width: 1
            radius: 5

            ScrollView {
                anchors.fill: parent
                anchors.margins: 10
                clip: true

                GridView {
                    id: previewGrid
                    cellWidth: 200
                    cellHeight: 200
                    model: []

                    delegate: Rectangle {
                        width: 190
                        height: 190
                        border.color: "#dddddd"
                        border.width: 1
                        radius: 5

                        Image {
                            anchors.fill: parent
                            anchors.margins: 5
                            source: modelData
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                border.color: "#999999"
                                border.width: 1
                                visible: parent.status === Image.Loading
                            }

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    console.log("Failed to load image:", source)
                                }
                            }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 5
                            width: 25
                            height: 20
                            color: "#333333"
                            radius: 3

                            Text {
                                anchors.centerIn: parent
                                text: (index + 1).toString()
                                color: "white"
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "No images loaded\nClick 'Open Images' to get started"
                font.pixelSize: 16
                color: "#888888"
                horizontalAlignment: Text.AlignHCenter
                visible: previewGrid.model.length === 0
            }
        }


    }
}
