//
//  ConversationTableViewCell.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import UIKit
import Elements

class ConversationTableCell :UITableViewCell {
    
    lazy var userImageView: BaseUIImageView = {
        let iv = BaseUIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
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
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    

    func configure(){ 
        contentView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func updateView(
        image: UIImage?,
        name : String,
        message : String
        
    ) {
        userImageView.image = image
        userNameLabel.text = name
        userMessageLabel.text = message
        
    }
    
//    let path = "\(item.otherUserEmail)_profile_picture.png"
//    StorageManager.shared.downloadURL(for: path) { [weak self] result  in
//        switch result {
//        case .success(let url):
//            DispatchQueue.main.async {
//                cell.userImageView.sd_setImage(with: url, completed: nil)
//            }
//        case .failure(let error):
//            print("failed to get image url: \(error)")
//        }
//    }

}


//    public func configure(with model: String)
