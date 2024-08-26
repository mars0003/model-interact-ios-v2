//
//  DownloadedModelsViewController.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import UIKit

class DownloadedModelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI Elements
    var tableView: UITableView!
    
    // ViewModel
    var viewModel = DownloadedModelsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Downloaded Models"
        setupTableView()
        viewModel.fetchAllModels { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // Set up the table view
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DownloadedModelCell")
        view.addSubview(tableView)
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.downloadedModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadedModelCell", for: indexPath)
        let modelURL = viewModel.downloadedModels[indexPath.row]
        
        cell.textLabel?.text = modelURL.lastPathComponent
        return cell
    }
    
    // UITableViewDelegate methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let modelURL = viewModel.downloadedModels[indexPath.row]
        
        print(modelURL)
        
        // Initialize WaterCycleViewController with necessary parameters
        let waterCycleVC = WaterCycleViewController()
         waterCycleVC.modelURL = modelURL

        
        // Pass any required data or model information to WaterCycleViewController
        // If WaterCycleViewController needs the modelURL or any other data, you can pass it here.
        // For example:
        
        navigationController?.pushViewController(waterCycleVC, animated: true)
    }
    
    // Enable swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteModel(at: indexPath.row) { [weak self] in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
