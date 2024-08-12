//
//  FirebaseManager.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 23/7/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager() // Singleton instance

    var modelName: String?
    var parts: [ModelClassification] = []
    let db = Firestore.firestore()
    
    private init() {} // Ensure this class can only be instantiated once

    func fetchParts(completion: @escaping ([ModelClassification]) -> Void) {
        guard let modelName = modelName else {
            print("Model name is not set.")
            completion([])
            return
        }
        
        db.collection("Models").document(modelName).collection("Parts").getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting parts: \(error)")
                completion([])
            } else {
                self.parts = snapshot?.documents.compactMap { ModelClassification(document: $0) } ?? []
                completion(self.parts)
            }
        }
    }
}
