//
//  ViewController.swift
//  MeasureMyRoom
//
//  Created by Steve Johnson on 06/08/2021.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

    }

    @IBAction func takeMeasurementsTouched(_ sender: Any) {
        let measurementViewController = MeasurementViewController()
        present(measurementViewController, animated: true, completion: nil)
    }
}
