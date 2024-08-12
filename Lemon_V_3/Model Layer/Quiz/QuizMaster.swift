//
//  QuizMaster.swift
//  Lemon
//
//  Created by Andre Pham on 25/8/2023.
//

import Foundation

class QuizMaster {
    
    /// The questions to ask - when every question is asked they repeat in order again
    private var questions = [Question]()
    /// The index of the active question from the questions list
    private var questionIndex: Int = -1
    /// If the quiz master is awaiting an audio answer (a spoken answer provided by the user)
    private(set) var readyForAudioAnswer = false
    /// If the quiz master is awaiting a visual answer (e.g. holding a specific part of the insect)
    private(set) var readyForVisualAnswer = false
    /// If the quiz master has received a question, but has not yet been flagged as ready for an answer
    private(set) var questionReceived = false
    private var loadedQuestion: Question {
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
//           AudioQuestion(
//                questionText: "What are my three main body segments?",
//                answers: [
//                    // It's hard to split these into variations - if you only expect x words you can't expect them broken up
//                    // E.g. mouthparts / mouth parts
//                    // Right now we just do every combination - not very pretty, but at least we can search for words that can be broken up
//                    // If we were have lists of every variation of a word, we couldn't search for words that are broken up (so we couldn't have a variation of "mouthparts" as "mouth" + "parts"
//                    // Ideally one day an optimal solution will be implemented
//                    ["head", "thorax", "abdomen"],
//                    ["how", "thorax", "abdomen"],
//                    ["had", "thorax", "abdomen"],
//                    ["add", "thorax", "abdomen"],
//                    ["heard", "thorax", "abdomen"],
//                    ["head", "thrax", "abdomen"],
//                    ["how", "thrax", "abdomen"],
//                    ["had", "thrax", "abdomen"],
//                    ["add", "thrax", "abdomen"],
//                    ["heard", "thrax", "abdomen"],
//                    ["head", "thorax", "admin"],
//                    ["how", "thorax", "admin"],
//                    ["had", "thorax", "admin"],
//                    ["add", "thorax", "admin"],
//                    ["heard", "thorax", "admin"],
//                    ["head", "thrax", "admin"],
//                    ["how", "thrax", "admin"],
//                    ["had", "thrax", "admin"],
//                    ["add", "thrax", "admin"],
//                    ["heard", "thrax", "admin"],
//                    ["headed", "thorax", "abdomen"],
//                    ["headed", "thrax", "abdomen"],
//                    ["headed", "thrax", "admin"],
//                    ["headed", "thorax", "admin"],
//                    ["have", "thorax", "abdomen"],
//                    ["have", "thrax", "abdomen"],
//                    ["have", "thrax", "admin"],
//                    ["have", "thorax", "admin"],
//                ]
//            ),
            
            AudioQuestion(
                questionText: "What is the primary source of energy for the water cycle?",
                answers: [["The Sun"], ["sun"]]
            ),
            AudioQuestion(
                questionText: "What term describes the process where water enters the soil?",
                answers: [["Infiltration"]]
            ),
            AudioQuestion(
                questionText: "What term is used for water flowing over the ground surface?",
                answers: [["Runoff"]]
            ),
            AudioQuestion(
                questionText: "What geographical features capture moisture and store water in the water cycle?",
                answers: [["Mountains"]]
            ),
            AudioQuestion(
                questionText: "What process involves plants releasing moisture into the atmosphere?",
                answers: [["Transpiration"]]
            ),
            AudioQuestion(
                questionText: "What process in the water cycle results in the formation of clouds?",
                answers: [["Condensation"]]
            ),
            AudioQuestion(
                questionText: "Which large body of saltwater plays a central role in the water cycle?",
                answers: [["Ocean"]]
            ),
            AudioQuestion(
                questionText: "What do arrows represent in water cycle diagrams?",
                answers: [["Flow"]]
            ),
            AudioQuestion(
                questionText: "What forms directly from water vapor under freezing conditions in the atmosphere?",
                answers: [["Snow"]]
            ),
            AudioQuestion(
                questionText: "What is the term for any form of water that falls from clouds to the ground?",
                answers: [["Precipitation"]]
            ),
//            VisualQuestion(
//                questionText: "Identify the process where water changes from a liquid to a gas in the water cycle.",
//                answers: [.evaporation]
//            ),
//            VisualQuestion(
//                questionText: "Identify the process where water from the surface seeps into the ground.",
//                answers: [.infiltration]
//            ),
            
            
            // tagmata
//            AudioQuestion(
//                questionText: "Which main body segment is connected to the wings?",
//                answers: [["thorax"], ["thrax"]]
//            ),
//            AudioQuestion(
//                questionText: "What three main receptor parts can be found on my head?",
//                answers: [["antenna", "eyes", "mouthparts"], ["antenna", "eyes", "mouth", "parts"]]
//            ),
//            AudioQuestion(
//                questionText: "What two parts make up my wing?",
//                answers: [
//                    ["for", "wing", "hind"],
//                    ["four", "wing", "hind"],
//                    ["forewing", "hindwing"],
//                    ["forewing", "hind", "wing"],
//                    ["for", "wing", "hindwing"],
//                    ["four", "wing", "hindwing"],
//                    ["for", "wing", "find"],
//                    ["four", "wing", "find"],
//                    ["forewing", "find"],
//                ]
//            ),
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
    
    func acceptAnswer(provided: SpeechText) -> AnswerStatus {
        let question = self.questions[questionIndex]
        if let audioQuestion = question as? AudioQuestion {
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
    
    func acceptAnswer(provided: TagmataClassification) -> AnswerStatus {
        let question = self.questions[questionIndex]
        if let visualQuestion = question as? VisualQuestion {
            let result = visualQuestion.checkAnswer(provided: provided)
            if result == .correct {
                // The question is complete - stop listening for answers
                self.readyForVisualAnswer = false
            }
            return result
        } else {
            assertionFailure("Answer was provided when the corresponding question wasn't ready")
            self.readyForVisualAnswer = false
            return .partial
        }
    }
    
}
