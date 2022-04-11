//
//  FloorPlanViewController.swift
//  MeasureMyRoom
//
//  Created by Steve Johnson on 17/08/2021.
//

import Foundation
import UIKit

class FloorPlanViewController: ViewController {

    @IBOutlet weak var floorPlanView: FloorPlanView!

    var measurements: [CGPoint] = []

    convenience init(measurements: [CGPoint]) {
        self.init()
        self.measurements = measurements
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        floorPlanView.measurements = measurements
    }
}
