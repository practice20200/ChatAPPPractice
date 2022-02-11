//
//  NewConversationViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import SwiftUI
import Elements
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users"
        return searchBar
    }()
    
    lazy var tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = UIColor.systemGray6
        table.layer.shadowColor = UIColor.lightGray.cgColor
        table.layer.opacity = 0.8
        return table
    }()
    
    lazy var noResultLabel : BaseUILabel = {
        let label =  BaseUILabel()
        label.isHidden = true
        label.text = "No Result"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.systemRed
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        searchBar.delegate = self
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSearcHandler))
        self.navigationItem.rightBarButtonItem = cancelButton
        navigationController?.navigationBar.topItem?.titleView = searchBar

        
        searchBar.becomeFirstResponder()
    }
    

    @objc func cancelSearcHandler(){
        dismiss(animated: true, completion: nil)
    }
    

}


extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
