//
//  AvailableModelCell.swift
//  Lemon_V_3
//
//  Created by Ishrat Kaur on 15/8/2024.
//

import UIKit

class AvailableModelCell: UITableViewCell {
    
    var downloadButtonAction: (() -> Void)?
    
    let modelNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "icloud.and.arrow.down"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.isHidden = true
        return progressView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(modelNameLabel)
        contentView.addSubview(downloadButton)
        contentView.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            modelNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            modelNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: modelNameLabel.trailingAnchor, constant: 10),
            progressView.trailingAnchor.constraint(equalTo: downloadButton.leadingAnchor, constant: -10),
            progressView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func downloadButtonTapped() {
        downloadButtonAction?()
    }
    
    func configureForDownload(progress: Double?) {
        if let progress = progress {
            downloadButton.isHidden = true
            progressView.isHidden = false
            progressView.progress = Float(progress) / 100
        } else {
            downloadButton.isHidden = false
            progressView.isHidden = true
        }
    }
}
