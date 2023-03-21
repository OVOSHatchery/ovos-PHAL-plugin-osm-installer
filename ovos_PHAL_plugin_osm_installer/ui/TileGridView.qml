import QtQuick 2.9
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.5 as Kirigami

GridView {
    id: view

    focus: true
    z: activeFocus ? 10: 1

    readonly property int columns: Math.max(1,
                    Math.min(maximumColumns > 0 ? maximumColumns : Infinity,
                                Math.floor(width/minimumColumnWidth),
                                Math.ceil(width/maximumColumnWidth))
                    );

    property int maximumColumns: Infinity
    property int maximumColumnWidth: Kirigami.Units.gridUnit * 20
    property int minimumColumnWidth: Kirigami.Units.gridUnit * 12

    cellWidth: Math.floor(width/columns)
    cellHeight: cellWidth * 0.5625 + Kirigami.Units.gridUnit * 2.5

    KeyNavigation.left: root
    KeyNavigation.right: root
}
