import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft
import QtGraphicalEffects 1.0

ItemDelegate {
    id: delegate
    property bool horizontalMode

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Rectangle {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        color: Kirigami.Theme.backgroundColor
        radius: 4

        Rectangle {
            id: nameBand
            color: Qt.lighter(Kirigami.Theme.backgroundColor, 1.5)
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 3
            border.color: Kirigami.Theme.highlightColor
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: Mycroft.Units.gridUnit / 2

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        source: model.logo
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: Text.WordWrap
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    text: model.title
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
            }
        }

        Item {
            anchors.top: nameBand.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: installedStatusBox.top
            anchors.margins: Kirigami.Units.smallSpacing

            Label {
                id: labelType
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.textColor
                wrapMode: Text.WordWrap
                text: model.description
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                clip: true
            }
        }

        Rectangle {
            id: installedStatusBox
            color: Kirigami.Theme.highlightColor
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: Kirigami.Units.gridUnit * 3
            border.color: Kirigami.Theme.backgroundColor
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.margins: Mycroft.Units.gridUnit / 2

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: height
                    Layout.alignment: Qt.AlignVCenter

                    Kirigami.Icon {
                        anchors.fill: parent
                        anchors.margins: 4
                        source: model.installed ? "answer-correct" : "install"

                        ColorOverlay {
                            anchors.fill: parent
                            source: parent
                            color: Kirigami.Theme.textColor
                        }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: Text.WordWrap
                    font.bold: true
                    color: Kirigami.Theme.textColor
                    text: model.installed ? qsTr("Installed") : qsTr("Available")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                    maximumLineCount: 2
                }
            }
        }
    }

    onClicked: {
        if(!model.installed) {
            installerPopBox.skillModel = model
            installerPopBox.open()
        }
    }
}
