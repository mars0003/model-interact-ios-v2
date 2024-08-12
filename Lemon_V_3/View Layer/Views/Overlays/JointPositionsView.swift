//
//  JointPositionsView.swift
//  Lemon
//
//  Created by Andre Pham on 7/7/2023.
//

import Foundation
import UIKit

class JointPositionsView: LemonUIView {
    
    public let view = UIView()
    
    func drawJointPositions(for handDetectionOutcome: HandDetectionOutcome) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        for positions in handDetectionOutcome.handDetections {
            for position in positions.holdingPositions {
                let positionVal = position.getDenormalisedPosition(for: self.view)
                if let positionVal {
                    let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 18.0*CGFloat(position.confidence!), height: 18.0*CGFloat(position.confidence!)))
                    circleView.center = positionVal
                    circleView.backgroundColor = UIColor.green
                    circleView.layer.cornerRadius = circleView.frame.width / 2
                    self.view.addSubview(circleView)
                }
            }
        }
    }
    
}
