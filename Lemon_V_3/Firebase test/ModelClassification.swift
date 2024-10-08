//
//  ModelClassification.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 23/7/2024.
//

//
//  ModelClassification.swift
//  Lemon_V_3
//
//  Created by Mohamed Asjad on 23/7/2024.
//

import Foundation
import FirebaseFirestore

struct ModelClassification: Hashable {
    var id: String
    var name: String
    var description: String
    var connection: String

    init?(document: DocumentSnapshot) {
        let data = document.data()
        self.id = document.documentID
        guard let name = data?["Name"] as? String,
              let description = data?["Info"] as? String,
              let connection = data?["Connect"] as? String else {
            return nil
        }
        
        // Remove extraneous quotes from the strings
        self.name = name.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        self.description = description.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        self.connection = connection.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    init?(data: [String: Any], documentID: String) {
        self.id = documentID
        guard let name = data["Name"] as? String,
              let description = data["Info"] as? String,
              let connection = data["Connect"] as? String else {
            return nil
        }
        
        self.name = name.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        self.description = description.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        self.connection = connection.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    // Fetch all model classifications for a given model from Firebase
    static func fetchModelClassifications(forModelID modelID: String, completion: @escaping ([ModelClassification]) -> Void) {
        let db = Firestore.firestore()
        let partsCollection = db.collection("Models").document(modelID).collection("Parts")
        
        partsCollection.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching parts: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            // Map each document to a ModelClassification object
            let classifications = documents.compactMap { ModelClassification(document: $0) }
            completion(classifications)
        }
    }

    // Fetch a single model classification by part ID
    static func fetchModelClassification(forModelID modelID: String, partID: String, completion: @escaping (ModelClassification?) -> Void) {
        let db = Firestore.firestore()
        let partDoc = db.collection("Models").document(modelID).collection("Parts").document(partID)
        
        partDoc.getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("Error fetching part \(partID): \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            let modelClassification = ModelClassification(document: document)
            completion(modelClassification)
        }
    }
}
