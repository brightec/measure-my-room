//
//  Grid.swift
//  NextReality_Tutorial2
//
//  Created by Ambuj Punn on 5/2/18.
//  Copyright © 2018 Next Reality. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Grid : SCNNode {

    private var gridSurfaceModifier = "float u = _surface.diffuseTexcoord.x; \n" +
        "float v = _surface.diffuseTexcoord.y; \n" +
        "int u100 = int(u * 50.0); \n" +
        "int v100 = int(v * 50.0); \n" +
        "if (u100 % 10 == 1 || v100 % 10 == 1) { \n" +
        "    // do nothing \n" +
        "} else { \n" +
        "    discard_fragment(); \n" +
        "} \n"

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
        planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))

        let pulseModifier = "#pragma transparent; \n" +
        "vec4 originalColour = _surface.diffuse; \n" +
        "vec4 transformed_position = u_inverseModelTransform * u_inverseViewTransform * vec4(_surface.position, 1.0); \n" +
        "vec2 xy = vec2(transformed_position.x, transformed_position.y); \n" +
        "float xyLength = length(xy); \n" +
            "float xyLengthNormalised = xyLength/" + String(describing: 0.1) + "; \n" +
        "float speedFactor = 1.5; \n" +
        "float maxDist = fmod(u_time, speedFactor) / speedFactor; \n" +
        "float distbasedalpha = step(maxDist, xyLengthNormalised); \n" +
        "distbasedalpha = max(distbasedalpha, maxDist); \n" +
        "_surface.diffuse = mix(originalColour, vec4(0.0), distbasedalpha);"

        planeGeometry.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.surface: gridSurfaceModifier
        ]
        planeGeometry.firstMaterial?.isDoubleSided = true
//        let floorNode = SCNNode(geometry: floorGeometry)
//
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named:"overlay_grid.png")
//
//        planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = 2
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);

        addChildNode(planeNode)
    }
}
