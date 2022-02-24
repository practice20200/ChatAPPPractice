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
    public var completion: ((SearchResult) -> Void)?
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    private var hasFetched = false
    private var results = [SearchResult]()
    
    
    // ============ Elements ============
    lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users"
        return searchBar
    }()
    
    lazy var tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationTableViewCell.self, forCellReuseIdentifier: "cell")
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

    
    // ============ Views ============
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(noResultLabel)
        view.addSubview(tableView)
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelSearcHandler))
        navigationItem.rightBarButtonItem = cancelButton
        navigationController?.navigationBar.topItem?.titleView = searchBar

        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.bounds.width/4, y: (view.bounds.height / -200)/2, width: view.bounds.width/2, height: 200)
    }

    
    
    
    
    // ============ Functions ============
    @objc func cancelSearcHandler(){
        dismiss(animated: true, completion: nil)
    }
    

}


extension NewConversationViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserData = results[indexPath.row]
        dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
}

extension NewConversationViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewConversationTableViewCell
        let item = results[indexPath.row]
//        cell.textLabel?.text = results[indexPath.row].name
        cell.userNameLabel.text = item.name
//        cell.userImageView.image = 
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}




extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{ return }
        results.removeAll()
        spinner.show(in: view)
        
        searchBar.resignFirstResponder()
        
        serachUsers(query: text)
        print("you found your friend successfully")
    }
    func serachUsers(query: String){
        if hasFetched{
            
        }
        else{
            DatabaseManager.shared.getAllUsers { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            }
        }
    }
    
    func filterUsers(with term: String){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else{ return }
        let safeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        self.spinner.dismiss()
        
        let results : [SearchResult] = users.filter({
            guard let email = $0["email"] ,email != safeEmail else{ return false }
            guard let name = $0["name"]?.lowercased() else { return false }
            return  name.hasPrefix(term.lowercased())
        }).compactMap { 
            guard let email = $0["email"] ,let name = $0["name"] else { return nil }
            return SearchResult(name: name, email: email)
        }
        
        self.results = results
        updateUI()
    }
    
    func updateUI(){
        if  results.isEmpty{
            noResultLabel.isHidden = false
            tableView.isHidden = true
        }else{
            noResultLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
}


struct SearchResult {
    let name: String
    let email: String
}
