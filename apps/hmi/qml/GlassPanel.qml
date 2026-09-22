import QtQuick
import OAS.HMI
Rectangle {
    radius: Theme.radius
    color: Theme.surface
    border.color: Theme.border
    border.width: 1
    gradient: Gradient {
        GradientStop { position: 0; color: "#19283a" }
        GradientStop { position: 1; color: "#101827" }
    }
}
