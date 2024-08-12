//
//  Question.swift
//  Lemon
//
//  Created by Andre Pham on 28/8/2023.
//

import Foundation

class Question {
    
    enum AnswerType {
        case audio
        case visual
    }
    
    public let questionText: String
    public let answerType: AnswerType
    
    init(questionText: String, answerType: AnswerType) {
        self.questionText = questionText
        self.answerType = answerType
    }
    
}
