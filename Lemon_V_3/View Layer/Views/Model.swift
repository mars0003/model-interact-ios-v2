//
//  Model.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import Foundation
import FirebaseFirestoreSwift

struct Model: Codable {
    @DocumentID var id: String?
    var name: String
    // Add other fields if necessary

    // Codable is necessary for Firestore decoding
}
