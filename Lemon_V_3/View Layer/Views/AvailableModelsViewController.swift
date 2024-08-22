//
//  AvailableModelsViewController.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import UIKit

class AvailableModelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // UI Elements
    var tableView: UITableView!
    
    // ViewModel
    var viewModel = AvailableModelsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Available Models"
        setupTableView()
        viewModel.fetchModels { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    // Set up the table view
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AvailableModelCell.self, forCellReuseIdentifier: "AvailableModelCell")
        view.addSubview(tableView)
    }
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailableModelCell", for: indexPath) as! AvailableModelCell
        let model = viewModel.models[indexPath.row]
        
        cell.modelNameLabel.text = model.name
        cell.downloadButtonAction = { [weak self] in
            self?.viewModel.downloadModel(model) { [weak self] in
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        if let isComplete = viewModel.downloadComplete[model.name], isComplete {
            cell.downloadButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
            cell.downloadButton.tintColor = .systemGreen
            cell.downloadButton.isEnabled = false
            cell.configureForDownload(progress: nil)
        } else if let progress = viewModel.downloadProgress[model.name] {
            cell.configureForDownload(progress: progress)
        } else {
            cell.downloadButton.setImage(UIImage(systemName: "icloud.and.arrow.down"), for: .normal)
            cell.downloadButton.tintColor = .systemBlue
            cell.downloadButton.isEnabled = true
            cell.configureForDownload(progress: nil)
        }
        
        return cell
    }
}
