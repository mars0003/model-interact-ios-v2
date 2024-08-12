//
//  LemonLabelledSwitch.swift
//  Lemon
//
//  Created by Andre Pham on 1/7/2023.
//

import Foundation
import UIKit

class LemonLabelledSwitch: LemonUIView {
    
    public let stack = LemonHStack()
    public let switchView = LemonSwitch()
    public let labelText = LemonText()
    public var view: UIView {
        return self.stack.view
    }
    
    override init() {
        super.init()
        self.stack
            .addView(self.labelText)
            .addView(self.switchView)
    }
    
}
