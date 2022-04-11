//
//  FloorPlanView.swift
//  MeasureMyRoom
//
//  Created by Steve Johnson on 17/08/2021.
//

import UIKit

class FloorPlanView: UIView {

    var viewBox: CGRect? = nil

    var measurements: [CGPoint] = [] {
        didSet {
            if (measurements.count > 0) {
                viewBox = viewBox(for: measurements)
            } else {
                viewBox = nil
            }
        }
    }

    override func draw(_ rect: CGRect) {
        guard let viewBox = self.viewBox else {
            return
        }

        let path = UIBezierPath()
        let indent = CGFloat(0.1)

        let xMove = rect.origin.x - viewBox.origin.x
        let yMove = rect.origin.y - viewBox.origin.y
        let widthScale = (1 / viewBox.size.width) * (rect.size.width * (1 - (indent * 2)))
        let heightScale = (1 / viewBox.size.height) * (rect.size.height * (1 - (indent * 2)))

//        let font = UIFont(name: "Arial", size: 10.0)
//        let fontColor = UIColor.red

        var firstMeasurement: CGPoint = .zero
        var lastMeasurement: CGPoint = .zero
        var firstPoint: CGPoint = .zero
        var lastPoint: CGPoint = .zero

        if (measurements.count > 0) {
            measurements.forEach { measurement in
                let point = CGPoint(
                    x: ((measurement.x + xMove) * widthScale) + (rect.size.width * indent),
                    y: ((measurement.y + yMove) * heightScale) + (rect.size.height * indent)
                )
                if measurement == measurements[0] {
                    firstMeasurement = measurement
                    firstPoint = point
                    lastPoint = point
                    lastMeasurement = measurement
                    path.move(to: point)
                } else {
                    let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blue ]
                    let string = NSAttributedString(string: String(format: "%.2fm", measurement.distance(to: lastMeasurement)), attributes: myAttribute)
                    string.draw(at: textPoint(point: midPoint(between: lastPoint, and: point), within: rect))
                    path.addLine(to: point)
                    lastPoint = point
                    lastMeasurement = measurement
                }
            }
            let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.darkGray ]
            let string = NSAttributedString(string: String(format: "%.2fm", lastMeasurement.distance(to: firstMeasurement)), attributes: myAttribute)
            string.draw(at: textPoint(point: midPoint(between: lastPoint, and: firstPoint), within: rect))
        }
        path.lineWidth = 5.0
        path.close()

        UIColor.black.set()
        UIColor.lightGray.setFill()

        path.stroke()
        path.fill()
    }

    func midPoint(between first: CGPoint, and second: CGPoint) -> CGPoint {
        print(first, second)
        return CGPoint(
            x: first.x + ((second.x - first.x) / 2),
            y: first.y + ((second.y - first.y) / 2)
        )
    }

    func textPoint(point: CGPoint, within rect: CGRect) -> CGPoint {
        return CGPoint(
            x: point.x + (point.x < (rect.origin.x + (rect.size.width / 2)) ? -30.0 : 10.0),
            y: point.y + (point.y < (rect.origin.y + (rect.size.height / 2)) ? -20.0 : 20.0)
        )
    }

    func viewBox(for measurements: [CGPoint]) -> CGRect {
        var minX = CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude

        measurements.forEach { point in
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        return CGRect(
            origin: CGPoint(x: minX, y: minY),
            size: CGSize(width: maxX - minX, height: maxY - minY)
        )
    }
}
