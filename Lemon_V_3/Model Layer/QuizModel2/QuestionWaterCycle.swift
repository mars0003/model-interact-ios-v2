//
//  QuestionWaterCycle.swift
//  Lemon
//
//  Created by Ishrat Kaur on 11/5/2024.
//

import Foundation

class QuestionWaterCycle {
    
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
