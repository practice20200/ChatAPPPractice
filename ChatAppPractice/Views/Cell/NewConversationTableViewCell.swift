//
//  NewConversationTableViewCell.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-20.
//

import Foundation
import UIKit
import Elements

class NewConversationTableViewCell: UITableViewCell {
    
    lazy var userImageView: BaseUIImageView = {
        let iv = BaseUIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.layer.masksToBounds = true
        iv.widthAnchor.constraint(equalToConstant: 50).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return iv
    }()
    
    lazy var userNameLabel: BaseUILabel = {
        let label = BaseUILabel()
//        label.textColor = UIColor.systemCyan
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
//    lazy var userMessageLabel: BaseUILabel = {
//        let label = BaseUILabel()
////        label.textColor = UIColor.systemCyan
//        label.font = .systemFont(ofSize: 19, weight: .regular)
//        label.numberOfLines = 0
//        return label
//    }()
    
    
//    lazy var contentStack: HStack = {
//        let stack = HStack()
//        stack.addArrangedSubview(userImageView)
//        stack.addArrangedSubview(userNameLabel)
//        stack.spacing = 16
//        stack.isLayoutMarginsRelativeArrangement = true
//        stack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
//        return stack
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        configure(with: SearchResult)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        
        NSLayoutConstraint.activate([
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        configure(with: SearchResult)
        fatalError("init(coder: ) has not beeb implemented")
    }
    

    public func configure(with model: SearchResult) {
           userNameLabel.text = model.name
        
        let safeEmail = DatabaseManager.safeEmail(email: model.email)

           let path = "images/\(safeEmail)_profile_picture.png"
           StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
               switch result {
                   case .success(let url):

                       DispatchQueue.main.async {
                           self?.userImageView.sd_setImage(with: url, completed: nil)
                       }

                   case .failure(let error):
                       print("failed to get image url: \(error)")
               }
           })
       }
}
