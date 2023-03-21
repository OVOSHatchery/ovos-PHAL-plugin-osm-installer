import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import org.kde.kirigami 2.11 as Kirigami
import Mycroft 1.0 as Mycroft

ListView {
    id: tileViewType
    anchors {
        left: parent.left
        right: parent.right
        top: header.baseline
        bottom: parent.bottom
        topMargin: Kirigami.Units.largeSpacing * 2
        leftMargin: -Kirigami.Units.largeSpacing
    }
    focus: true

    z: activeFocus ? 10: 1
    keyNavigationEnabled: true

    //Centering disabled as experiment
    highlightRangeMode: ListView.ApplyRange

    highlightFollowsCurrentItem: true
    snapMode: ListView.SnapToItem
    cacheBuffer: width
    implicitHeight: cellHeight
    rightMargin: width-cellWidth
    property int cellWidth: (Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing*4)
    property int cellHeight: cellWidth + Kirigami.Units.gridUnit * 3
    preferredHighlightBegin: 0
    preferredHighlightEnd: cellWidth
    displayMarginBeginning: cellWidth
    displayMarginEnd: cellWidth

    highlightMoveVelocity: -1
    highlightMoveDuration: Kirigami.Units.longDuration

//     onContentWidthChanged: if (tileViewType.view.currentIndex === 0) tileViewType.view.contentX = tileViewType.view.originX

    //onMovementEnded: flickEnded()
    //onFlickEnded: tileViewType.currentIndex = indexAt(mapToItem(tileViewType.contentItem, tileViewType.cellWidth, 0).x, 0)

    spacing: 0
    property bool horizontalMode
    orientation: horizontalMode ? ListView.Horizontal : ListView.Vertical

    move: Transition {
        SmoothedAnimation {
            property: "x"
            duration: Kirigami.Units.longDuration
        }
    }
} 
