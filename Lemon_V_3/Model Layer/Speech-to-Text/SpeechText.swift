//
//  SpeechText.swift
//  Lemon
//
//  Created by Andre Pham on 23/6/2023.
//

import Foundation

class SpeechText {
    
    public let text: String
    public let words: [String]
    public var lastWord: String {
        return self.words.last!
    }
    
    init(text: String) {
        self.text = text.lowercased()
        self.words = self.text.components(separatedBy: " ")
    }
    
    func getWords(without filterWords: [String]) -> [String] {
        return words.filter { word in
            !filterWords.contains(word)
        }
    }
    
    func contains(_ command: Command) -> Bool {
        for commandString in command.strings {
            if self.contains(commandString) {
                return true
            }
        }
        return false
    }
    
    func contains(_ text: String) -> Bool {
        return self.text.contains(text.lowercased())
    }
    
    func count(_ text: String) -> Int {
        return self.text.components(separatedBy: text.lowercased()).count - 1
    }
    
    
}
