import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

ItemDelegate {
    id: installBoxRoot
    property bool opened: false
    property var skillModel
    property var installerStatus: sessionData.installer_status ? sessionData.installer_status : 0
    visible: installBoxRoot.opened ? 1 : 0
    enabled: installBoxRoot.opened ? 1 : 0
    width: parent.width
    height: parent.height

    Keys.onEscapePressed: {
        close()
    }

    function open() {
        installBoxRoot.opened = true
        installBoxRoot.forceActiveFocus()
    }

    function close() {
        installBoxRoot.opened = false
        parent.forceActiveFocus()
    }

    onOpenedChanged: {
        installBoxRoot.installerStatus = 0
    }

    onInstallerStatusChanged: {
        switch(installerStatus){
            case 0: break;
            case 1: break;
            case 2: installBoxRoot.close(); break;
            case 3: installBoxRoot.close(); break;
        }
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

                Rectangle {
                    id: nameBand
                    color: Kirigami.Theme.highlightColor
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
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

                            Image {
                                anchors.fill: parent
                                anchors.margins: 4
                                source: skillModel.logo
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            wrapMode: Text.WordWrap
                            font.bold: true
                            color: Kirigami.Theme.textColor
                            text: skillModel.title
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            maximumLineCount: 2
                        }
                    }
                }

                ProgressBar {
                    id: barInstallerLower
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    padding: 4
                    indeterminate: installBoxRoot.installerStatus == 1 && installBoxRoot.visible ? 1 : 0
                }

                Button {
                    id: buttonLower
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                    enabled: !skillModel.installed
                    text: qsTr("Install")

                    onClicked: {
                        console.log(installBoxRoot.skillModel)
                        //triggerGuiEvent("osm.installer.install", {"url": skillModel.url})
                    }
                }
            }
        }
    }
}
