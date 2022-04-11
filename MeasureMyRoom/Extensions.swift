//
//  Extensions.swift
//  MeasureMyRoom
//
//  Created by Steve Johnson on 08/08/2021.
//

import Foundation
import ARKit

extension FloatingPoint {
    var degreesToRadians: Self {
        return self * .pi / 180
    }
    var radiansToDegrees: Self {
        return self * 180 / .pi
    }
}

extension SCNVector3 {
    func distance(to destination: SCNVector3) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        let dz = destination.z - z
        return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
    }
}

extension CGPoint {
    func distance(to destination: CGPoint) -> CGFloat {
        let dx = destination.x - x
        let dy = destination.y - y
        return CGFloat(sqrt(dx * dx + dy * dy))
    }
}
