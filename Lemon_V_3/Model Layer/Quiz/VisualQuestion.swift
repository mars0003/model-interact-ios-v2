//
//  VisualQuestion.swift
//  Lemon
//
//  Created by Andre Pham on 28/8/2023.
//

import Foundation

class VisualQuestion: Question {
    
    private let answers: [TagmataClassification]
    
    init(questionText: String, answers: [TagmataClassification]) {
        self.answers = answers
        super.init(questionText: questionText, answerType: .visual)
    }
    
    func checkAnswer(provided: TagmataClassification) -> AnswerStatus {
        for answer in self.answers {
            if provided == answer {
                return .correct
            }
        }
        return .incorrect
    }
    
}
