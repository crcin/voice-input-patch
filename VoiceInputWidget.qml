import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    visibilityCommand: "[ -f /tmp/voice-status ] && [ \"$(cat /tmp/voice-status)\" != \"idle\" ]"
    visibilityInterval: 1

    property string _instanceId: Math.random().toString(36).substring(2, 10)
    property string _status: "idle"
    property real _pulseOpacity: 1.0

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            Proc.runCommand(root._instanceId + ".readStatus", ["cat", "/tmp/voice-status"], (out, code) => {
                _status = code === 0 ? out.trim() : "idle"
            }, 0)
        }
    }

    Timer {
        id: pulseTimer
        interval: 800
        running: _status === "recording"
        repeat: true
        onTriggered: _pulseOpacity = _pulseOpacity === 1.0 ? 0.4 : 1.0
    }

    Connections {
        target: pulseTimer
        function onRunningChanged() {
            if (!pulseTimer.running) _pulseOpacity = 1.0
        }
    }

    horizontalBarPill: Component {
        Item {
            readonly property string st: root._status
            readonly property real pulseOpacity: root._pulseOpacity

            implicitWidth: iconSize
            implicitHeight: widgetThickness

            readonly property int iconSize: Theme.barIconSize(barThickness, -4, barConfig?.maximizeWidgetIcons, barConfig?.iconScale)

            DankIcon {
                id: icon
                anchors.centerIn: parent
                name: st === "transcribing" ? "sync" : "mic"
                size: parent.iconSize
                color: st === "recording" ? Theme.error
                     : st === "transcribing" ? Theme.secondary
                     : Theme.widgetTextColor
                opacity: st === "recording" ? parent.pulseOpacity : 1.0

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Theme.standardEasing }
                }

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Theme.standardEasing }
                }
            }
        }
    }

    verticalBarPill: Component {
        Item {
            readonly property string st: root._status
            readonly property real pulseOpacity: root._pulseOpacity

            implicitWidth: widgetThickness
            implicitHeight: iconSize

            readonly property int iconSize: Theme.barIconSize(barThickness, undefined, barConfig?.maximizeWidgetIcons, barConfig?.iconScale)

            DankIcon {
                id: icon
                anchors.centerIn: parent
                name: st === "transcribing" ? "sync" : "mic"
                size: parent.iconSize
                color: st === "recording" ? Theme.error
                     : st === "transcribing" ? Theme.secondary
                     : Theme.widgetTextColor
                opacity: st === "recording" ? parent.pulseOpacity : 1.0

                Behavior on opacity {
                    NumberAnimation { duration: 200; easing.type: Theme.standardEasing }
                }

                Behavior on color {
                    ColorAnimation { duration: 200; easing.type: Theme.standardEasing }
                }
            }
        }
    }

    pillClickAction: (x, y, width, section, screen) => {
        Proc.runCommand(root._instanceId + ".click", ["bash", "-c", "~/.local/bin/voice-input cancel"], function(out, code) {}, 0)
    }
}
