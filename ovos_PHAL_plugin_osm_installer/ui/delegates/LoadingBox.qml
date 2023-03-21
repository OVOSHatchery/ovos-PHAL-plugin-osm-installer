import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

ItemDelegate {
    id: loadingBoxRoot
    property bool opened: false
    visible: loadingBoxRoot.opened ? 1 : 0
    enabled: loadingBoxRoot.opened ? 1 : 0
    width: parent.width
    height: parent.height

    function open() {
        loadingBoxRoot.opened = true
    }

    function close() {
        console.log("Should close")
        loadingBoxRoot.opened = false
    }

    background: Rectangle {
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.3)
    }

    contentItem: BusyIndicator {
        running: loadingBoxRoot.opened ? 1 : 0
    }
}
