//
//  VisualQuestionWaterCycle.swift
//  Lemon
//
//  Created by Ishrat Kaur on 11/5/2024.
//

import Foundation

class VisualQuestionWaterCycle: QuestionWaterCycle {
    
    private let answers: [ModelClassification]
    
    init(questionText: String, answers: [ModelClassification]) {
        self.answers = answers
        super.init(questionText: questionText, answerType: .visual)
    }
    
    func checkAnswer(provided: ModelClassification) -> AnswerStatusWaterCycle {
        for answer in self.answers {
            if provided == answer {
                return .correct
            }
        }
        return .incorrect
    }
    
}
