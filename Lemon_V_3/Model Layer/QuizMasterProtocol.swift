//
//  QuizMasterProtocol.swift
//  Lemon
//
//  Created by Ishrat Kaur on 16/5/2024.
//

import Foundation

protocol QuizMasterProtocol {
    
    func startQuiz()
    func stopQuiz()
    var readyForAudioAnswer: Bool { get }
    var readyForVisualAnswer: Bool { get }
    var questionReceived: Bool { get set }
    var loadedQuestionText: String { get }
    func isActivatedBy(speech: SpeechText, useShorthand: Bool) -> Bool
    func markQuestionAsReceived(_ received: Bool)
    func loadNextQuestion()
    func loadCurrentQuestion()
    func markReadyForAnswer()
    func acceptAnswer(provided: SpeechText) -> AnswerStatusWaterCycle
    func acceptAnswer(provided: ModelClassification) -> AnswerStatusWaterCycle
    
}
