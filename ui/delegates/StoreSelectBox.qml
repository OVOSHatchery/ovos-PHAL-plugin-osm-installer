import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

ItemDelegate {
    id: storeSelectBoxRoot
    property bool opened: false
    property var activeStores: sessionData.appstore_stores_model.active_stores
    visible: storeSelectBoxRoot.opened ? 1 : 0
    enabled: storeSelectBoxRoot.opened ? 1 : 0
    width: parent.width
    height: parent.height

    Keys.onEscapePressed: {
        close()
    }

    function open() {
        storeSelectBoxRoot.opened = true
        storeSelectBoxRoot.forceActiveFocus()
    }

    function close() {
        storeSelectBoxRoot.opened = false
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

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: storeSelectBoxRoot.activeStores

                    delegate: Button {
                        id: providerButton
                        width: parent.width
                        height: Kirigami.Units.gridUnit * 3

                        background: Rectangle {
                            id: providerBand
                            color: Kirigami.Theme.backgroundColor
                            border.color: Kirigami.Theme.highlightColor
                            border.width: 1
                            radius: 4
                        }

                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.margins: Mycroft.Units.gridUnit / 2

                            Label {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                wrapMode: Text.WordWrap
                                font.bold: true
                                font.capitalization: Font.AllUppercase
                                color: Kirigami.Theme.textColor
                                text: modelData.store
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                maximumLineCount: 2
                            }
                        }

                        onClicked: {
                            triggerGuiEvent("osm.installer.select.display.store", {
                                "store": modelData.store
                            })
                            storeSelectBoxRoot.close()
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
                        storeSelectBoxRoot.close()
                    }
                }
            }
        }
    }
}
