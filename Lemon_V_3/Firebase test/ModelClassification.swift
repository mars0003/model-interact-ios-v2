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
}


