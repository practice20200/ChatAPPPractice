//
//  ViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-06.
//

import UIKit
import FirebaseAuth
import Elements
import JGProgressHUD
import SwiftUI

struct Conversation{
    let id: String
    let name: String
    let otherUserEmail: String
    let lastestMessage: LatestMessage
}

struct LatestMessage{
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationViewController: UIViewController {

    ////===================== elements ======================
    private let spinner = JGProgressHUD(style: .dark)
    private var conversations = [Conversation]()
    private var loginObserver: NSObjectProtocol?
    
    lazy var tableView : UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = UIColor.systemGray6
        table.layer.shadowColor = UIColor.lightGray.cgColor
        table.layer.opacity = 0.8
        return table
    }()
        
    lazy var noConversationLabel : BaseUILabel = {
        let label =  BaseUILabel()
        label.text = "No Conversaiton"
        label.font = UIFont.systemFont(ofSize: 21, weight: .medium)
        label.textColor = UIColor.gray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    
    
    
    //===================== views ======================
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setUpTableView()
        fetchConverssations()
        startListeningForConversations()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoadNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf .startListeningForConversations()
        })
        
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeHandler))
        self.navigationItem.rightBarButtonItem = composeButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tableView.frame = view.bounds
//        view.addSubview(noConversationLabel)
//        view.addSubview(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
        
    }
    
    
    
    
    
    //===================== functions ======================
    
    private func startListeningForConversations(){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else{ return }
        print("check1=======")
        if let observer = loginObserver{
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        print("check2:  \(email)=======")
        print("check2:  \(DatabaseManager.safeEmail(email: email))=======")
        //to prevent memory cicle weak self when tableView is reloaded
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("check3=======")
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        }
    }
    
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    private func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConverssations(){
        tableView.isHidden = false
    }
    
    
    //===================== Buttons ======================
    @objc func composeHandler(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            //print("\(result)")
            self?.createrNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createrNewConversation( result: SearchResult){
        
        let name = result.name
        let email = result.email
        print(" reate new Conversation is OK")
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension ConversationViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = conversations[indexPath.row]
        
        let vc = ChatViewController(with: item.otherUserEmail, id: item.id)
        vc.title = item.name
        vc.navigationController?.pushViewController(vc, animated: true)
       
    }
}

extension ConversationViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationTableCell
        let item = conversations[indexPath.row]
////        cell.userImageView.image =
//        cell.userNameLabel.text = item.name
//        cell.userMessageLabel.text = item.lastestMessage.text
      
        
        cell.updateView(image: UIImage(named:""), name: item.name, message: item.lastestMessage.text)
        
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        return if editingStyle == .delete {
            tableView.beginUpdates()
            conversations.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .left)
            
            
            tableView.endUpdates()
        }
    }

}





