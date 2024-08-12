//
//  QuizMasterWaterCycle.swift
//  Lemon
//
//  Created by Ishrat Kaur on 11/5/2024.
//

import Foundation


class QuizMasterWaterCycle {
    
    /// The questions to ask - when every question is asked they repeat in order again
    private var questions = [QuestionWaterCycle]()
    /// The index of the active question from the questions list
    private var questionIndex: Int = -1
    /// If the quiz master is awaiting an audio answer (a spoken answer provided by the user)
    private(set) var readyForAudioAnswer = false
    /// If the quiz master is awaiting a visual answer (e.g. holding a specific part of the insect)
    private(set) var readyForVisualAnswer = false
    /// If the quiz master has received a question, but has not yet been flagged as ready for an answer
    private(set) var questionReceived = false
    private var loadedQuestion: QuestionWaterCycle {
        return self.questions[self.questionIndex]
    }
    public var loadedQuestionText: String {
        return self.questions[self.questionIndex].questionText
    }
    public var activationPhrases: [String] {
        return ["quiz me", "chris me", "because me", "christening"]
    }
    public var shorthandActivationPhrases: [String] {
        return ["quiz", "chris"]
    }
    
    init() {
        self.questions = [
            AudioQuestionWaterCycle(
                questionText: "What is the primary source of energy for the water cycle?",
                answers: [["The Sun"], ["sun"], ["Son"]]
            ),
//            VisualQuestionWaterCycle(
//                questionText: "Identify the process where water from the surface seeps into the ground.",
//                answers: [.infiltration]
//            ),
            AudioQuestionWaterCycle(
                questionText: "What term describes the process where water enters the soil?",
                answers: [["Infiltration"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What term is used for water flowing over the ground surface?",
                answers: [["Runoff"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What geographical features capture moisture and store water in the water cycle?",
                answers: [["Mountains"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What process involves plants releasing moisture into the atmosphere?",
                answers: [["Transpiration"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What process in the water cycle results in the formation of clouds?",
                answers: [["Condensation"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "Which large body of saltwater plays a central role in the water cycle?",
                answers: [["Ocean"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What do arrows represent in water cycle diagrams?",
                answers: [["Flow"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What forms directly from water vapor under freezing conditions in the atmosphere?",
                answers: [["Snow"]]
            ),
            AudioQuestionWaterCycle(
                questionText: "What is the term for any form of water that falls from clouds to the ground?",
                answers: [["Precipitation"]]
            ),
//            VisualQuestionWaterCycle(
//                questionText: "Identify the process where water changes from a liquid to a gas in the water cycle.",
//                answers: [.evaporation]
//            )
            
//            VisualQuestion(
//                questionText: "Can you identify my left wing?",
//                answers: [.leftWing]
//            )
        ]
    }
    
    func isActivatedBy(speech: SpeechText, useShorthand: Bool = false) -> Bool {
        let phrases = useShorthand ? self.shorthandActivationPhrases : self.activationPhrases
        for phrase in phrases {
            if speech.contains(phrase) {
                return true
            }
        }
        return false
    }
    
    func markQuestionAsReceived(_ received: Bool) {
        self.questionReceived = received
    }
    
    func loadNextQuestion() {
        // Reset ready-for answers (just in case)
        self.readyForAudioAnswer = false
        self.readyForVisualAnswer = false
        self.questionIndex = (questionIndex + 1)%self.questions.count
    }
    
    func loadCurrentQuestion() {
        // Reset ready-for answers (just in case)
        self.readyForAudioAnswer = false
        self.readyForVisualAnswer = false
    }
    
    func markReadyForAnswer() {
        switch self.loadedQuestion.answerType {
        case .audio:
            self.readyForAudioAnswer = true
        case .visual:
            self.readyForVisualAnswer = true
        }
    }
    
    func acceptAnswer(provided: SpeechText) -> AnswerStatusWaterCycle {
        let question = self.questions[questionIndex]
        if let audioQuestion = question as? AudioQuestionWaterCycle {
            let result = audioQuestion.checkAnswer(provided: provided)
            if result == .correct {
                // The question is complete - stop listening for answers
                self.readyForAudioAnswer = false
            }
            return result
        } else {
            assertionFailure("Answer was provided when the corresponding question wasn't ready")
            self.readyForAudioAnswer = false
            return .partial
        }
    }
    
    func acceptAnswer(provided: ModelClassification) -> AnswerStatusWaterCycle {
        let question = self.questions[questionIndex]
        if let visualQuestion = question as? VisualQuestionWaterCycle {
            let result = visualQuestion.checkAnswer(provided: provided)
            if result == .correct {
                // The question is complete - stop listening for answers
                self.readyForVisualAnswer = false
            }
            //
            return result
        } else {
            assertionFailure("Answer was provided when the corresponding question wasn't ready")
            self.readyForVisualAnswer = false
            return .partial
        }
    }
    
}
