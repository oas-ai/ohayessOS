import QtQuick
import OAS.HMI
Rectangle {
    radius: Theme.radius
    color: Theme.surface
    border.color: Theme.border
    border.width: 1
    gradient: Gradient {
        GradientStop { position: 0; color: Theme.surfaceTop }
        GradientStop { position: 1; color: Theme.surfaceBottom }
    }
}
