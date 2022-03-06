//
//  ConversationTableViewCell.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import UIKit
import Elements
import SDWebImage

class ConversationTableCell :UITableViewCell {
    
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
    
    lazy var userMessageLabel: BaseUILabel = {
        let label = BaseUILabel()
//        label.textColor = UIColor.systemCyan
        label.font = .systemFont(ofSize: 19, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    
    lazy var contentStack: HStack = {
        let stack = HStack()
        stack.addArrangedSubview(userImageView)
        stack.addArrangedSubview(userNameLabel)
        stack.addArrangedSubview(userMessageLabel)
        stack.spacing = 16
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 20)
//        stack.backgroundColor = .blue
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        
        NSLayoutConstraint.activate([
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.trailingAnchor, constant: 20),
            
            userMessageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userMessageLabel.leadingAnchor.constraint(equalTo: userNameLabel.trailingAnchor, constant: 20),
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder: ) has not beeb implemented")
    }
    

    func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name

        let path = "images/\(model.otherUserEmail)_profile_picture.png"
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

