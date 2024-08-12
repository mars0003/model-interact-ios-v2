//
//  LemonLabelledSlider.swift
//  Lemon
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation
import UIKit

class LemonLabelledSlider: LemonUIView, LemonViewObserver {
    
    public let stack = LemonHStack()
    public let slider = LemonSlider()
    public let labelText = LemonText()
    public let valueText = LemonText()
    public var view: UIView {
        return self.stack.view
    }
    
    override init() {
        super.init()
        self.stack
            .addView(self.labelText)
            .addView(self.slider)
            .addView(self.valueText)
        self.viewStateDidChange(self.slider)
        self.slider.subscribe(self)
    }
    
    func viewStateDidChange(_ view: LemonUIView) {
        if view.id == self.slider.id { // In case we add other views
            self.valueText.setText(to: "\(Int(self.slider.value))")
        }
    }
    
}
