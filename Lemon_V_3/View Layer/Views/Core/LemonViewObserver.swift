//
//  ViewObserver.swift
//  Lemon
//
//  Created by Andre Pham on 30/6/2023.
//

import Foundation

protocol LemonViewPublisher: AnyObject {
    
    var subscribers: [WeakLemonViewObserver] { get set }
    
}
extension LemonViewPublisher {
    
    func subscribe(_ subscriber: LemonViewObserver) {
        self.subscribers.append(WeakLemonViewObserver(value: subscriber))
    }
    
    func publish(_ view: LemonUIView) {
        for sub in self.subscribers {
            sub.value?.viewStateDidChange(view)
        }
    }
    
}


protocol LemonViewObserver: AnyObject {
    
    func viewStateDidChange(_ view: LemonUIView)
    
}


class WeakLemonViewObserver {
    
    private(set) weak var value: LemonViewObserver?

    init(value: LemonViewObserver?) {
        self.value = value
    }
    
}
