import QtQuick

Rectangle {
    id: root
    color: "#000000"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            anchors.centerIn: parent
            source: "images/arch-logo.png"
            sourceSize.width: 566
            sourceSize.height: 188
            width: 566
            height: 188
            smooth: true
            mipmap: true
        }

        Image {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            y: logo.y + logo.height + 28
            source: "images/busy.png"
            sourceSize.width: 32
            sourceSize.height: 32
            width: 32
            height: 32
            smooth: true

            RotationAnimator on rotation {
                id: rotationAnimator
                from: 0
                to: 360
                duration: 1500
                loops: Animation.Infinite
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: true
        target: content
        from: 0
        to: 1
        duration: 300
        easing.type: Easing.InOutQuad
    }
}
