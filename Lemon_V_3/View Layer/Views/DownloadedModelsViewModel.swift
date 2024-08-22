//
//  DownloadedModelsViewModel.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import Foundation

class DownloadedModelsViewModel {
    @Published var downloadedModels: [URL] = []
    
    func fetchAllModels(completion: @escaping () -> Void) {
        let fileManager = FileManager.default
        let documentsURL = getDocumentsDirectory()
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            let modelURLs = fileURLs.filter { $0.pathExtension == "mlmodel" || $0.pathExtension == "mlmodelc" }
            DispatchQueue.main.async {
                self.downloadedModels = modelURLs
                completion()
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
    }
    
    func deleteModel(at index: Int, completion: @escaping () -> Void) {
        let fileManager = FileManager.default
        let modelURL = downloadedModels[index]
        
        do {
            try fileManager.removeItem(at: modelURL)
            downloadedModels.remove(at: index)
            completion()
        } catch {
            print("Error deleting file \(modelURL.path): \(error.localizedDescription)")
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
