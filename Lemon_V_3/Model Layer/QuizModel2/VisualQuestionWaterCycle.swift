//
//  VisualQuestionWaterCycle.swift
//  Lemon
//
//  Created by Ishrat Kaur on 11/5/2024.
//

import Foundation
import Firebase

class VisualQuestionWaterCycle: QuestionWaterCycle {
    
    private let answers: [ModelClassification]
    
    // Initialize with question text and answers fetched from Firebase
    init(questionText: String, answers: [ModelClassification]) {
        self.answers = answers
        super.init(questionText: questionText, answerType: .visual)
    }
    
    // Method to check if the provided answer is correct
    func checkAnswer(provided: ModelClassification) -> AnswerStatusWaterCycle {
        for answer in self.answers {
            if provided == answer {
                return .correct
            }
        }
        return .incorrect
    }
    
    // Function to convert the raw Firebase data into ModelClassification objects
    static func from(firebaseData: [String: Any], modelID: String, completion: @escaping (VisualQuestionWaterCycle?) -> Void) {
        guard let questionText = firebaseData["questionText"] as? String,
              let rawAnswers = firebaseData["answers"] as? [String] else {
            completion(nil)
            return
        }
        
        // Fetch the model classifications from Firebase based on the provided answers (e.g., part IDs)
        fetchModelClassifications(forAnswers: rawAnswers, modelID: modelID) { modelClassifications in
            let question = VisualQuestionWaterCycle(questionText: questionText, answers: modelClassifications)
            completion(question)
        }
    }
    
    // Fetch the ModelClassification objects from Firebase using answer IDs
    static func fetchModelClassifications(forAnswers answerIDs: [String], modelID: String, completion: @escaping ([ModelClassification]) -> Void) {
        let db = Firestore.firestore()
        var classifications = [ModelClassification]()
        let group = DispatchGroup()  // To handle async fetches

        for answerID in answerIDs {
            group.enter()  // Enter the dispatch group before fetching each part
            let partRef = db.collection("Models").document(modelID).collection("Parts").document(answerID)
            
            partRef.getDocument { (document, error) in
                if let document = document, document.exists, let data = document.data() {
                    let modelPart = ModelClassification(data: data, documentID: document.documentID)
                    if let part = modelPart {
                        classifications.append(part)
                    }
                } else {
                    print("Error fetching part \(answerID): \(error?.localizedDescription ?? "Unknown error")")
                }
                group.leave()  // Leave the dispatch group after fetching the part
            }
        }
        
        // Once all parts are fetched, return the list of classifications
        group.notify(queue: .main) {
            completion(classifications)
        }
    }
}
