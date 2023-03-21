import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

ItemDelegate {
    id: settingsBoxRoot
    property bool opened: false
    property var allStores: sessionData.appstore_stores_model.all_stores
    visible: settingsBoxRoot.opened ? 1 : 0
    enabled: settingsBoxRoot.opened ? 1 : 0
    width: parent.width
    height: parent.height

    Keys.onEscapePressed: {
        close()
    }

    function open() {
        settingsBoxRoot.opened = true
        settingsBoxRoot.forceActiveFocus()
        console.log(JSON.stringify(settingsBoxRoot.allStores))
    }

    function close() {
        settingsBoxRoot.opened = false
        parent.forceActiveFocus()
    }

    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.3)
    }

    contentItem: Item {

        MouseArea {
            anchors.fill: parent
            onClicked: {
                close()
            }
        }

        Rectangle {
            width: parent.width * 0.75
            height: parent.height * 0.75
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            color: Kirigami.Theme.backgroundColor
            radius: 4

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                id: contentAreaMainColumn
                anchors.fill: parent
                anchors.margins: Mycroft.Units.gridUnit / 2

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3

                    Label {
                        anchors.fill: parent
                        anchors.margins: Mycroft.Units.gridUnit / 2
                        text: qsTr("Enabled Stores")
                        font.pixelSize: height * 0.5
                        font.bold: true
                    }

                    Kirigami.Separator {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        color: Kirigami.Theme.textColor
                    }
                }
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    rows: 2

                    Repeater {
                        id: storesRepeater
                        model: settingsBoxRoot.allStores

                        delegate: RowLayout { 
                            spacing: Mycroft.Units.gridUnit / 2

                            CheckBox {
                                id: providerButton
                                Layout.fillHeight: true
                                checked: modelData.active

                                onClicked: {
                                    if(modelData.store != delRoot.defaultStore) {
                                        if(!modelData.active){
                                            triggerGuiEvent("osm.installer.activate.store", {
                                                "store": modelData.store
                                            })
                                        } else {
                                            triggerGuiEvent("osm.installer.deactivate.store", {
                                                "store": modelData.store
                                            })
                                        }
                                    }
                                }
                            }

                            Label {
                                id: providerLabel
                                Layout.fillWidth: parent.width
                                Layout.fillHeight: true
                                verticalAlignment: Text.AlignVCenter
                                font.capitalization: Font.AllUppercase
                                text: modelData.store
                                color: Kirigami.Theme.textColor
                            }
                        }
                    }
                }

                Button {
                    id: buttonLower
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    enabled: !skillModel.installed
                    text: qsTr("Close")

                    onClicked: {
                        settingsBoxRoot.close()
                    }
                }
            }
        }
    }
}
