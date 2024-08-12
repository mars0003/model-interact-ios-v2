//
//  ProximityView.swift
//  Lemon
//
//  Created by Andre Pham on 7/7/2023.
//

import Foundation
import UIKit

class ProximityView: LemonUIView {
    
    public let view = UIView()
    
    func drawProximityJoints(tagmataDetectionOutcome: TagmataDetectionOutcome, handDetectionOutcome: HandDetectionOutcome) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        let tagmataPositions = tagmataDetectionOutcome.tagmataDetections.map({ $0.getDenormalisedCenter(for: self.view) })
        for positions in handDetectionOutcome.handDetections {
            for position in positions.holdingPositions {
                guard let positionVal = position.getDenormalisedPosition(for: self.view) else {
                    continue
                }
                var minDistance: CGFloat? = nil
                var closestPoint = CGPoint()
                for tagmataPosition in tagmataPositions {
                    let distance = tagmataPosition.length(to: positionVal)
                    if minDistance == nil || isLess(distance, minDistance!) {
                        minDistance = distance
                        closestPoint = tagmataPosition
                    }
                }
                if let minDistance {
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 18.0*CGFloat(position.confidence!), height: 18.0*CGFloat(position.confidence!)))
                    circleView.center = positionVal
                    circleView.backgroundColor = UIColor.green
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.view.addSubview(circleView)
                    let distanceLabel = UILabel()
                    distanceLabel.text = "\(Double(minDistance).rounded(decimalPlaces: 0))"
                    distanceLabel.font = UIFont.boldSystemFont(ofSize: 14)
                    distanceLabel.textColor = UIColor.white
                    distanceLabel.textAlignment = .right
                    distanceLabel.sizeToFit()
                    distanceLabel.center = positionVal
                    distanceLabel.backgroundColor = isLess(minDistance, 80) ? .green : .black
                    if isLess(minDistance, 80) {
                        self.drawLine(positionVal, closestPoint)
                    }
                    self.view.addSubview(distanceLabel)
                }
            }
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
