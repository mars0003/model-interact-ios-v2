//
//  MainViewController.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
            super.viewDidLoad()
        }
    
    @IBAction func ViewAvailableModels(_ sender: Any) {
        let availableModelsVC = AvailableModelsViewController()
        navigationController?.pushViewController(availableModelsVC, animated: true)
    }
    
    @IBAction func ViewDownloadedModels(_ sender: Any) {
        let downloadedModelsVC = DownloadedModelsViewController()
        navigationController?.pushViewController(downloadedModelsVC, animated: true)
    }
    
}
