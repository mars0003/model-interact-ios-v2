//
//  QuizMasterWaterCycle.swift
//  Lemon
//
//  Created by Ishrat Kaur on 11/5/2024.
//

import Foundation
import Firebase

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
    
    public var activationPhrases: [String] {
        return ["quiz me", "chris me", "because me", "christening"]
    }
    public var shorthandActivationPhrases: [String] {
        return ["quiz", "chris"]
    }
    
    private var loadedQuestion: QuestionWaterCycle {
        return self.questions[self.questionIndex]
    }
    public var loadedQuestionText: String {
        return self.questions[self.questionIndex].questionText
    }
        
        init(modelID: String) {
            fetchQuestions(forModel: modelID)
        }
    
    // Fetch questions from Firestore based on the selected model
    func fetchQuestions(forModel modelID: String) {
        let db = Firestore.firestore()
        db.collection("Models").document(modelID).collection("Quiz").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching questions: \(error)")
                return
            }
            self.questions = querySnapshot?.documents.compactMap { document -> QuestionWaterCycle? in
                let data = document.data()
                guard let questionText = data["questionText"] as? String,
                      let answerType = data["answerType"] as? String else {
                    return nil
                }
                
                if answerType == "audio" {
                    let answers = data["answers"] as? [[String]] ?? []
                    return AudioQuestionWaterCycle(questionText: questionText, answers: answers)
                } else if answerType == "visual" {
                    let answers = data["answers"] as? [ModelClassification] ?? []
                    return VisualQuestionWaterCycle(questionText: questionText, answers: answers)
                } else {
                    return nil
                }
            } ?? []
        }
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
        readyForAudioAnswer = false
        readyForVisualAnswer = false
        questionIndex = (questionIndex + 1) % questions.count
    }
    
    func loadCurrentQuestion() {
        // Reset ready-for answers (just in case)
        self.readyForAudioAnswer = false
        self.readyForVisualAnswer = false
    }
    
    func markReadyForAnswer() {
        switch loadedQuestion.answerType {
        case .audio:
            readyForAudioAnswer = true
        case .visual:
            readyForVisualAnswer = true
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
