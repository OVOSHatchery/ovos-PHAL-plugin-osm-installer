import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

ItemDelegate {
    id: searchBoxRoot
    property bool opened: false
    visible: searchBoxRoot.opened ? 1 : 0
    enabled: searchBoxRoot.opened ? 1 : 0
    width: parent.width
    height: parent.height

    Keys.onEscapePressed: {
        close()
    }

    function open() {
        searchBoxRoot.opened = true
        searchBoxRoot.forceActiveFocus()
    }

    function close() {
        searchBoxRoot.opened = false
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
            height: contentAreaMainColumn.implicitHeight + Mycroft.Units.gridUnit
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

                TextField {
                    id: searchAreaTextField
                    Layout.fillWidth: true
                    Layout.preferredHeight: Mycroft.Units.gridUnit * 4

                    onAccepted: {
                        triggerGuiEvent("osm.installer.search", {"description": searchAreaTextField.text})
                        searchBoxRoot.close()
                    }
                }

                Button {
                    id: buttonLower
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    enabled: !skillModel.installed
                    text: qsTr("Search")

                    onClicked: {
                       triggerGuiEvent("osm.installer.search", {"description": searchAreaTextField.text})
                       searchBoxRoot.close()
                    }
                }
            }
        }
    }
}
