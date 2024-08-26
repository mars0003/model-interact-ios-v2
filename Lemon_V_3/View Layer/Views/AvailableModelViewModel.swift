//
//  AvailableModelViewModel.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class AvailableModelsViewModel {
    @Published var models: [Model] = []
    @Published var downloadProgress: [String: Double] = [:]
    @Published var downloadComplete: [String: Bool] = [:]

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // Fetch models from Firestore
    func fetchModels(completion: @escaping () -> Void) {
        db.collection("Models").getDocuments { [weak self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self?.models = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Model.self)
                } ?? []
                self?.checkLocalFiles()
                completion()
            }
        }
    }

    // Check if models are already downloaded locally
    func checkLocalFiles() {
        for model in models {
            let localURL = getDocumentsDirectory().appendingPathComponent("\(model.name).mlmodelc")
            if FileManager.default.fileExists(atPath: localURL.path) {
                downloadComplete[model.name] = true
                UserDefaults.standard.set(localURL.path, forKey: model.name)
            } else {
                downloadComplete[model.name] = false
            }
        }
    }

    // Download the model from Firebase and save it to the Documents directory
    func downloadModel(_ model: Model, completion: @escaping () -> Void) {
        let localURL = getDocumentsDirectory().appendingPathComponent("\(model.name).mlmodel")

        // Check if file already exists
        if FileManager.default.fileExists(atPath: localURL.path) {
            downloadComplete[model.name] = true
            UserDefaults.standard.set(localURL.path, forKey: model.name)
            completion()
            return
        }

        let storageRef = storage.reference().child("models/\(model.name).mlmodel")

        let downloadTask = storageRef.write(toFile: localURL) { [weak self] url, error in
            if let error = error {
                print("Error downloading model: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self?.downloadComplete[model.name] = true
                self?.downloadProgress[model.name] = nil
                // Save the file path to UserDefaults
                UserDefaults.standard.set(localURL.path, forKey: model.name)
                completion()
            }
        }

        downloadTask.observe(.progress) { [weak self] snapshot in
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                DispatchQueue.main.async {
                    self?.downloadProgress[model.name] = percentComplete
                }
            }
        }
    }

    // Function to get the path to the Documents directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
