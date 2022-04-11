//
//  MeasurementViewController.swift
//  MeasureMyRoom
//
//  Created by Steve Johnson on 17/08/2021.
//

import UIKit
import SceneKit
import ARKit

class MeasurementViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var instructionsLabel: UILabel!

    private var floor: SCNNode?

    private var measurements: [CGPoint] = []

    private var markers: [SCNNode] = []
    private var isComplete: Bool = false
    private let configuration = ARWorldTrackingConfiguration()

    private var yFirstMarkerEulerOffset: ((SCNNode) -> Float)?

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configuration.planeDetection = .horizontal
        configuration.sceneReconstruction = .meshWithClassification
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (floor === nil) {
            guard let location = touches.first?.location(in: sceneView) else {
                print("Couldn't find a touch")
                return
            }
            guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .horizontal) else {
                print("Couldn't create a query!")
                return
            }
            guard let result = sceneView.session.raycast(query).first else {
                print("Couldn't match the raycast with a plane.")
                return
            }
            setFloor(result: result)
            markers = []
            configuration.planeDetection = .vertical
            sceneView.session.run(configuration)
        } else {
            guard let location = touches.first?.location(in: sceneView) else {
                // In a production app we should provide feedback to the user here
                print("Couldn't find a touch")
                return
            }
            guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .vertical) else {
                // In a production app we should provide feedback to the user here
                print("Couldn't create a query!")
                return
            }
            guard let result = sceneView.session.raycast(query).first else {
                print("Couldn't match the raycast with a plane!")
                return
            }
            addMeasurement(result: result)
        }
        updateInstructionsLabel()
    }

    private func gridSurfaceModifier(density: CGFloat) -> String {
        return "float u = _surface.diffuseTexcoord.x; \n" +
            "float v = _surface.diffuseTexcoord.y; \n" +
            "int u100 = int(u * \(density)); \n" +
            "int v100 = int(v * \(density)); \n" +
            "if (u100 % 10 == 1 || v100 % 10 == 1) { \n" +
            "    // do nothing \n" +
            "} else { \n" +
            "    discard_fragment(); \n" +
            "} \n"
    }

    private func updateInstructionsLabel() {
        switch (true) {
        case isComplete:
            instructionsLabel.text = "Measurements complete"
        case floor !== nil && markers.count == 0:
            instructionsLabel.text = "Add your first corner"
        case floor !== nil && markers.count > 0:
            instructionsLabel.text = "Continue adding corners, tap the orange marker to complete measurements"
        default:
            instructionsLabel.text = "Tap to set floor"
        }
    }

    private func createFloorNode() -> SCNNode {
        let floorGeometry = SCNPlane(width: 0.5, height: 0.5)
        floorGeometry.firstMaterial?.shaderModifiers = [
            SCNShaderModifierEntryPoint.surface: gridSurfaceModifier(density: 500)
        ]
        floorGeometry.firstMaterial?.isDoubleSided = true
        let floorNode = SCNNode(geometry: floorGeometry)
        return floorNode
    }

    private func setFloor(result: ARRaycastResult) {
        floor = createFloorNode()
        if let node = floor {
            node.transform = SCNMatrix4(result.worldTransform)
            node.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }

    private func set(node: SCNNode, color: UIColor) {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor(white: 1, alpha: 1.0)
        node.geometry?.materials = [material]
    }

    private func createSphereNode() -> SCNNode {
        let sphereGeometry = SCNSphere(radius: 0.01)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        set(node: sphereNode, color: UIColor.green)
        return sphereNode
    }

    private func isPoint(_ firstPoint: Float, within range: Float, of secondPoint: Float) -> Bool {
        return (secondPoint > firstPoint - range && secondPoint < firstPoint + range)
    }

    private func isNode(_ firstNode: SCNNode, within range: Float, of secondNode: SCNNode) -> Bool {
        let first = firstNode.position
        let second = secondNode.position
        if (!isPoint(first.x, within: range, of: second.x)) {
            return false
        }
        if (!isPoint(first.y, within: range, of: second.y)) {
            return false
        }
        if (!isPoint(first.z, within: range * 10, of: second.z)) {
            return false
        }
        return true
    }

    private func addMeasurement(result: ARRaycastResult) {
        if (isComplete) {
            return
        }

        let thisMarker = createSphereNode()
        let rootNode = sceneView.scene.rootNode
        thisMarker.transform = SCNMatrix4(result.worldTransform)
        rootNode.addChildNode(thisMarker)
        let thisMeasurement = CGPoint(x: CGFloat(thisMarker.position.x), y: CGFloat(thisMarker.position.z))

        guard let firstMarker = markers.first,
              let lastMarker = markers.last,
              let yEulerOffset = yFirstMarkerEulerOffset else {
            markers.append(thisMarker)
            measurements.append(thisMeasurement)
            yFirstMarkerEulerOffset = { node in
                let angle = node.eulerAngles.y
                return angle - (0 - thisMarker.eulerAngles.y)
            }
            return
        }

        print(yEulerOffset(thisMarker).radiansToDegrees)

        if isNode(firstMarker, within: 0.1, of: thisMarker) {
            set(node: firstMarker, color: .green)
            isComplete = true
            addCorner(between: lastMarker, and: firstMarker)
            thisMarker.removeFromParentNode()
            let floorplanVC = FloorPlanViewController(measurements: measurements)
            present(floorplanVC, animated: true, completion: nil)
        } else {
            markers.append(thisMarker)
            measurements.append(thisMeasurement)
        }

        if (!isComplete && markers.count > 0) {
            set(node: firstMarker, color: .orange)
        }
        if (!isComplete && markers.count > 1) {
            addCorner(between: lastMarker, and: thisMarker)
        }
    }

    private func addCorner(between firstNode: SCNNode, and secondNode: SCNNode) {
        let cylinder = TrigCylinder(from: firstNode.position, to: secondNode.position)
        sceneView.scene.rootNode.addChildNode(cylinder)
    }

    func posBetween(first: SCNVector3, second: SCNVector3) -> SCNVector3 {
            return SCNVector3Make((first.x + second.x) / 2, (first.y + second.y) / 2, (first.z + second.z) / 2)
    }

    private func TrigCylinder(from node1: SCNVector3, to node2: SCNVector3) -> SCNNode {

        let first = SCNVector3(
            node1.x,
            floor?.position.y ?? 0,
            node1.z
        )
        let second = SCNVector3(
            node2.x,
            floor?.position.y ?? 0,
            node2.z
        )

        // Create Cylinder Geometry
        let line = SCNCylinder(radius: 0.005, height: first.distance(to: second))

        // Create Material
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .phong
        line.materials = [material]

        let lineGroup = SCNNode()

        // Create Cylinder(line) Node
        let hypotenuse = SCNNode()
        hypotenuse.geometry = line
        hypotenuse.position = posBetween(first: first, second: second)

        // This is the change in x,y and z between node1 and node2
        let dirVector = SCNVector3Make(second.x - first.x, second.y - first.y, second.z - first.z)

        // Get Y rotation in radians
        let destAngle = atan(first.x / first.z)
        let originAngle = atan(second.x / second.z)
        let yAngle = atan(dirVector.x / dirVector.z)

        // Rotate cylinder node about X axis so cylinder is laying down
        hypotenuse.eulerAngles.x = .pi / 2

        // Rotate cylinder node about Y axis so cylinder is pointing to each node
        hypotenuse.eulerAngles.y = yAngle

        let originLine = SCNNode()
        originLine.geometry = line
        originLine.position = first
        originLine.eulerAngles.x = .pi / 2
        originLine.eulerAngles.y = originAngle

        let destLine = SCNNode()
        destLine.geometry = line
        destLine.position = second
        destLine.eulerAngles.x = .pi / 2
        destLine.eulerAngles.y = destAngle

        lineGroup.addChildNode(hypotenuse)

        return lineGroup
    }

}
