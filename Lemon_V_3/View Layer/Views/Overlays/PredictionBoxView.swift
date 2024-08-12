//
//  PredictionBoxView.swift
//  Lemon
//
//  Created by Andre Pham on 14/6/2023.
//

import Foundation
import UIKit

class PredictionBoxView: LemonUIView {
    
    public let view = UIView()
    
    func drawBoxes(for predictionOutcome: TagmataDetectionOutcome, plainOutline: UIColor? = nil) {
        self.view.subviews.forEach({ $0.removeFromSuperview() })
        self.view.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        for prediction in predictionOutcome.tagmataDetections {
            if let plainOutline {
                self.drawOutline(for: prediction, color: plainOutline)
            } else {
                self.drawBox(for: prediction)
            }
        }
    }
    
    private func drawOutline(for prediction: TagmataDetection, color: UIColor) {
        let rect = prediction.getDenormalisedBoundingBox(boundsWidth: self.view.bounds.width, boundsHeight: self.view.bounds.height)
        let newLayer = UIView()
        newLayer.frame = rect
        newLayer.layer.borderColor = color.withAlphaComponent(CGFloat(prediction.confidence)).cgColor
        newLayer.layer.borderWidth = 3.0
        newLayer.layer.cornerRadius = 4
        self.view.addSubview(newLayer)
        let label = UILabel()
        label.text = prediction.label
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = prediction.classification.color
        label.textAlignment = .right
        label.sizeToFit()
        label.center = CGPoint(x: rect.origin.x + label.frame.width/2.0, y: rect.origin.y + label.frame.height/2.0)
        self.view.addSubview(label)
    }
    
    private func drawBox(for prediction: TagmataDetection) {
        let rect = prediction.getDenormalisedBoundingBox(boundsWidth: self.view.bounds.width, boundsHeight: self.view.bounds.height)
        let newLayer = UIView()
        newLayer.frame = rect
        newLayer.backgroundColor = prediction.classification.color.withAlphaComponent(0.2)
        newLayer.layer.cornerRadius = 4
        self.view.addSubview(newLayer)
        let label = UILabel()
        label.text = "\(prediction.label) \((100.0*prediction.confidence).toString(decimalPlaces: 0))%"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .center
        label.sizeToFit()
        label.center = rect.center
        self.view.addSubview(label)
        let positionLabel = UILabel()
        positionLabel.text = rect.center.toString()
        positionLabel.font = UIFont.boldSystemFont(ofSize: 14)
        positionLabel.textColor = UIColor.black
        positionLabel.textAlignment = .right
        positionLabel.sizeToFit()
        positionLabel.center = CGPoint(x: rect.origin.x + positionLabel.frame.width/2.0, y: rect.origin.y + positionLabel.frame.height/2.0)
        self.view.addSubview(positionLabel)
    }
    
}
