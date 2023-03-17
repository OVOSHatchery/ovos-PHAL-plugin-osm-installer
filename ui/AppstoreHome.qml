import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import "delegates" as Delegate
import QtGraphicalEffects 1.0

Mycroft.Delegate {
    id: delRoot
    skillBackgroundColorOverlay: Kirigami.Theme.backgroundColor
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    property bool lviewFirstItem: lview.view.currentIndex != 0 ? 1 : 0
    property var selectedStore
    property bool horizontalMode: delRoot.width > delRoot.height ? 1 : 0
    property var defaultStore: sessionData.default_store

    onGuiEvent: {
        switch(eventName) {
            case "osm.installer.display.store.change.started":
                console.log("Store change started")
                loaderPopBox.open()
                break;
            case "osm.installer.display.store.change.finished":
                console.log("Store change finished")
                loaderPopBox.close()
                break;
            case "osm.installer.display.store.changed":
                console.log("Store changed")
                delRoot.selectedStore = data.store
                loaderPopBox.close()
                break;
            case "osm.installer.stores.model.updating":
                console.log("Updating stores model")
                loaderPopBox.open()
                break;
            case "osm.installer.stores.model.updated":
                console.log("Stores model updated")
                loaderPopBox.close()
                break;
        }
    }

    Component.onCompleted: {
        triggerGuiEvent("osm.installer.dashboard.loaded", {})
    }

    Rectangle {
        anchors.fill: parent
        
        gradient: Gradient {
            GradientStop {
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
                position: 0.0
            }
            GradientStop {
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
                position: 0.10
            }
            GradientStop {
                color:  Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.4)
                position: 0.50
            }
            GradientStop {
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
                position: 0.90
            }
            GradientStop {
                color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 1)
                position: 1
            }
        }

        Rectangle {
            id: topBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Mycroft.Units.gridUnit * 3
            color: Kirigami.Theme.backgroundColor

            Label {
                id: globalStoreLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: Mycroft.Units.gridUnit / 2
                font.bold: true
                font.pixelSize: height * 0.9
                color: Kirigami.Theme.textColor
                text: "OSM Store"
            }

            Button {
                id: searchStore
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: sortStore.left
                anchors.rightMargin: Mycroft.Units.gridUnit / 2
                width: Mycroft.Units.gridUnit * 2
                height: width

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Kirigami.Icon {
                    source: Qt.resolvedUrl("images/search.png")

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                onClicked: {
                    loaderPopBox.close()
                    installerPopBox.close()
                    storeSelectPopBox.close()
                    settingsPopBox.close()
                    searchPopBox.open()
                }
            }

            Button {
                id: sortStore
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: topBarAreaCloseButton.left
                anchors.rightMargin: Mycroft.Units.gridUnit / 2
                width: Mycroft.Units.gridUnit * 2
                height: width

                background: Rectangle {
                    color: "transparent"
                }

                contentItem: Kirigami.Icon {
                    source: Qt.resolvedUrl("images/settings.png")

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                onClicked: {
                    loaderPopBox.close()
                    installerPopBox.close()
                    storeSelectPopBox.close()
                    searchPopBox.close()
                    settingsPopBox.open()
                }
            }

            Rectangle {
                id: topBarAreaCloseButton
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Mycroft.Units.gridUnit * 4
                color: Kirigami.Theme.highlightColor

                Kirigami.Icon {
                    id: closeIcon
                    anchors.centerIn: parent
                    width: Mycroft.Units.gridUnit * 1.8
                    height: Mycroft.Units.gridUnit * 1.8
                    source: "window-close-symbolic"

                    ColorOverlay {
                        anchors.fill: parent
                        source: parent
                        color: Kirigami.Theme.textColor
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        triggerGuiEvent("osm.installer.close", {})
                    }
                }
            }

            Kirigami.Separator {
                color: Kirigami.Theme.highlightColor
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
            }
        }

        Item {
            anchors.top: topBar.bottom
            anchors.bottom: bottomBar.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Mycroft.Units.gridUnit / 2

            Item {
                id: leftarrow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: Kirigami.Units.iconSizes.large
                visible: delRoot.horizontalMode ? 1 : 0
                enabled: delRoot.horizontalMode ? 1 : 0

                Kirigami.Icon {
                    source: Qt.resolvedUrl("images/left.png")
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    anchors.centerIn: parent
                    enabled: lviewFirstItem
                    opacity: lviewFirstItem ? 1 : 0.4
                }
            }

            Item {
                id: centeringItem
                anchors.top: parent.top
                anchors.left: delRoot.horizontalMode ? leftarrow.right : parent.left
                anchors.right: delRoot.horizontalMode ? rightarrow.left : parent.right
                anchors.bottom: parent.bottom

                TileView {
                    id: lview
                    focus: true
                    width: parent.width
                    height: parent.height
                    cellWidth: parent.width / 3.25
                    clip: true
                    anchors.centerIn: parent
                    horizontalMode: delRoot.horizontalMode
                    model: sessionData.appstore_display_model
                    delegate: Delegate.TileDelegate {
                        horizontalMode: delRoot.horizontalMode
                        implicitWidth: horizontalMode ? lview.cellWidth : lview.width
                        height: horizontalMode ? lview.height : lview.height / 2
                    }
                }
            }

            Item {
                id: rightarrow
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: Kirigami.Units.iconSizes.large
                visible: delRoot.horizontalMode ? 1 : 0
                enabled: delRoot.horizontalMode ? 1 : 0

                Kirigami.Icon {
                    source: Qt.resolvedUrl("images/right.png")
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    anchors.centerIn: parent
                    enabled: lview.currentIndex != (lview.view.count - 1) ? 1 : 0
                    opacity: lview.currentIndex != (lview.view.count - 1) ? 1 : 0.4
                }
            }
        }

        Rectangle {
            id: bottomBar
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: delRoot.horizontalMode ? Mycroft.Units.gridUnit * 4 : Mycroft.Units.gridUnit * 6
            color: Kirigami.Theme.backgroundColor

            GridLayout {
                anchors.fill: parent
                columnSpacing: 0
                rowSpacing: 0
                columns: delRoot.horizontalMode ? 2 : 1

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Mycroft.Units.gridUnit * 2

                    Label {
                        anchors.fill: parent
                        width: parent.width / 2
                        height: parent.height
                        color: Kirigami.Theme.textColor
                        font.bold: true
                        font.pixelSize: height * 0.6
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: qsTr("Selected Store") + ": " + delRoot.selectedStore
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Mycroft.Units.gridUnit * 4

                    Button {
                        id: changeStoreButton
                        anchors.fill: parent
                        anchors.margins: Mycroft.Units.gridUnit / 2

                        background: Rectangle {
                            color: changeStoreButton.down ? Kirigami.Theme.highlightColor :  Kirigami.Theme.backgroundColor
                            border.width: 1
                            border.color: Kirigami.Theme.highlightColor
                            radius: 3
                        }

                        contentItem: Item {
                            RowLayout {
                                anchors.centerIn: parent

                                Kirigami.Icon {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: height
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "code-block"

                                    ColorOverlay {
                                        anchors.fill: parent
                                        source: parent
                                        color: Kirigami.Theme.textColor
                                    }
                                }

                                Kirigami.Heading {
                                    level: 2
                                    Layout.fillHeight: true
                                    wrapMode: Text.WordWrap
                                    font.bold: true
                                    color: changeStoreButton.down ? Kirigami.Theme.backgroundColor : Kirigami.Theme.textColor
                                    text: qsTr("Change Store")
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }
                        }

                        onClicked: {
                            loaderPopBox.close()
                            installerPopBox.close()
                            searchPopBox.close()
                            settingsPopBox.close()
                            storeSelectPopBox.open()
                        }
                    }
                }
            }
        }

        Delegate.LoadingBox {
            id: loaderPopBox
            z: 10
        }

        Delegate.StoreSelectBox {
            id: storeSelectPopBox
        }

        Delegate.SearchBox {
            id: searchPopBox
        }

        Delegate.InstallerBox {
            id: installerPopBox
        }

        Delegate.SettingsBox {
            id: settingsPopBox
        }
    }
}
