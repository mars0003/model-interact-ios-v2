//
//  AudioQuestionWaterCycle.swift
//  Lemon
//
//  Created by Ishrat Kaur on 11/5/2024.
//

import Foundation

class AudioQuestionWaterCycle: QuestionWaterCycle {
    
    private let answers: [[String]]
    
    init(questionText: String, answers: [[String]]) {
        self.answers = answers
        super.init(questionText: questionText, answerType: .audio)
    }
    
    func checkAnswer(provided: SpeechText) -> AnswerStatusWaterCycle {
        for answer in answers {
            let sanitisedProvided = sanitiseAnswer(answer: provided)
            if answer.contains(where: { sanitisedProvided.contains($0) }) {
                return .correct
            }
        }
        return .incorrect
    }
    
    private func sanitiseAnswer(answer: SpeechText) -> [String] {
        let wordsToRemove = [
            // Filler words
            "and", "a", "do", "the",
            // Quiz-trigger words (received when receiving original speech to activate the quiz but delayed)
            "quiz", "me", "chris",
            // Quiz-response words (to avoid an infinite recursion loop of hearing the feedback as an answer)
            "please", "try", "again"
        ]
        return answer.getWords(without: wordsToRemove)
    }
    
}
