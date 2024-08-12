//
//  NewModelProximityView.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 24/7/2024.
//

import Foundation
import UIKit

class ModelProximityView: LemonUIView {
    
    public let view = UIView()
    
    func drawProximityJoints(modelDetectionOutcome: NewModelDetectionOutcome) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        let modelPositions = modelDetectionOutcome.modelDetections.map({ $0.getDenormalisedCenter(for: self.view) })
        for tagmataPosition in modelPositions {
            let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 18.0, height: 18.0))
            circleView.center = tagmataPosition
            circleView.backgroundColor = UIColor.green
            circleView.layer.cornerRadius = circleView.frame.width / 2
            self.view.addSubview(circleView)
        }
    }
    
    private func drawLine(_ point1: CGPoint, _ point2: CGPoint) {
        let linePath = UIBezierPath()
        linePath.move(to: point1)
        linePath.addLine(to: point2)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = linePath.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 1.0

        self.view.layer.addSublayer(shapeLayer)
    }
    
}
