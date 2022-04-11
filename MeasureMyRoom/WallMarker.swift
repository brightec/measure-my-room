//
//  WallMarker.swift
//  MeasureMyRoom
//
//  Created by Steve Johnson on 12/08/2021.
//

import Foundation
import SceneKit
import ARKit

class WallMarker : SCNNode {

    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!

    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x);
        planeGeometry.height = CGFloat(anchor.extent.z);
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);

        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    }

    private func setup() {
        planeGeometry = SCNPlane(width: 0.05, height: 0.05)

        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"cr_wall")

        planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = 2

        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);

        addChildNode(planeNode)
    }
}
