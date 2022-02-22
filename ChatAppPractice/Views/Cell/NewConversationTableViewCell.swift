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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        configure(with: SearchResult)
        fatalError("init(coder: ) has not beeb implemented")
    }
    

    func configure(with model: SearchResult){
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        NSLayoutConstraint.activate([
            userImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant:  10),
            userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            userNameLabel.leadingAnchor.constraint(equalTo: userImageView.leadingAnchor, constant: 15),
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func updateView(
        image: UIImage?,
        name : String
//        message : String
        
    ) {
        userImageView.image = image
        userNameLabel.text = name
//        userMessageLabel.text = message
        
    }
}
