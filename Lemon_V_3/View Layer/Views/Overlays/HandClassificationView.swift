//
//  HandClassificationView.swift
//  Lemon
//
//  Created by Andre Pham on 14/7/2023.
//

import Foundation
import UIKit

class HandClassificationView: LemonUIView {
    
    public let view = UIView()
    
    func drawHandClassification(for handDetectionOutcome: HandDetectionOutcome) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        for handDetection in handDetectionOutcome.handDetections {
            var chiralityLabel: String = ""
            if let chirality = handDetection.chirality {
                chiralityLabel = chirality.rawValue
            }
            var classificationLabel: String = ""
            if let classification = handDetection.classification {
                classificationLabel = classification.toString()
            }
            if chiralityLabel.count + classificationLabel.count > 0 {
                let allX = handDetection.allPositions.compactMap({ $0.getDenormalisedPosition(for: self.view)?.x })
                let allY = handDetection.allPositions.compactMap({ $0.getDenormalisedPosition(for: self.view)?.y })
                
                for position in handDetection.allPositions {
                    let positionVal = position.getDenormalisedPosition(for: self.view)
                    if let positionVal {
                        let circleView = UIView(frame: CGRect(x: 0, y: 0, width: 9.0*CGFloat(position.confidence ?? 0.0), height: 9.0*CGFloat(position.confidence ?? 0.0)))
                        circleView.center = positionVal
                        circleView.backgroundColor = UIColor.green.withAlphaComponent(0.4)
                        circleView.layer.cornerRadius = circleView.frame.width / 2
                        self.view.addSubview(circleView)
                    }
                }
                
                if let minX = allX.min(), let minY = allY.min(), let maxX = allX.max(), let maxY = allY.max() {
                    let boundingBox = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                    let newLayer = UIView()
                    newLayer.frame = boundingBox
                    var color = UIColor.black
                    if handDetection.classification?.label == .stop && isGreater(handDetection.classification?.confidence ?? 0.0, 0.9) {
                        color = UIColor.red
                    }
                    newLayer.layer.borderColor = color.withAlphaComponent(CGFloat(handDetection.classification?.confidence ?? 0.0)).cgColor
                    newLayer.layer.borderWidth = 3.0
                    newLayer.layer.cornerRadius = 4
                    self.view.addSubview(newLayer)
                    
                    let classificationLabelView = UILabel()
                    classificationLabelView.text = classificationLabel
                    classificationLabelView.font = UIFont.boldSystemFont(ofSize: 14)
                    classificationLabelView.textColor = UIColor.black
                    classificationLabelView.backgroundColor = .white
                    classificationLabelView.textAlignment = .right
                    classificationLabelView.sizeToFit()
                    classificationLabelView.center = CGPoint(
                        x: boundingBox.origin.x + classificationLabelView.frame.width/2.0,
                        y: boundingBox.origin.y + classificationLabelView.frame.height/2.0
                    )
                    self.view.addSubview(classificationLabelView)
                    
                    let chiralityLabelView = UILabel()
                    chiralityLabelView.text = chiralityLabel
                    chiralityLabelView.font = UIFont.boldSystemFont(ofSize: 14)
                    chiralityLabelView.textColor = UIColor.black
                    chiralityLabelView.backgroundColor = .white
                    chiralityLabelView.textAlignment = .right
                    chiralityLabelView.sizeToFit()
                    chiralityLabelView.center = CGPoint(
                        x: boundingBox.origin.x + chiralityLabelView.frame.width/2.0,
                        y: boundingBox.origin.y + boundingBox.height - chiralityLabelView.frame.height/2.0
                    )
                    self.view.addSubview(chiralityLabelView)
                }
            }
        }
    }
    
}
