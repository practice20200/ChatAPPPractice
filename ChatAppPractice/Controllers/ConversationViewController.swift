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


final class ConversationViewController: UIViewController {

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
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(tableView)
        view.addSubview(noConversationLabel)
        setUpTableView()
        startListeningForConversations()
        print("the number of current conversations (conversations.count): \(conversations.count)")
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil , queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.startListeningForConversations()
        })
        
        
        let composeButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeHandler))
        navigationItem.rightBarButtonItem = composeButton
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationLabel.frame = CGRect(x: 10, y: (view.bounds.height-100)*1/2, width: view.bounds.width-20, height: 100)
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
        print("====== Starting conversation fetch =======")
        let safeEmail = DatabaseManager.safeEmail(email: email)
        print("check2 success:  \(email)=======")
        print("check2 success:  \(DatabaseManager.safeEmail(email: email))=======")
        //to prevent memory cicle weak self when tableView is reloaded
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("check3: successfully got conversation models=======")
                    self?.tableView.isHidden = false
                    self?.noConversationLabel.isHidden = false
                    return
                }
                self?.noConversationLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationLabel.isHidden = false
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
    
    private func createrNewConversation( result: SearchResult){
        
        let name = result.name
        let email = DatabaseManager.safeEmail(email: result.email)
        print(" Create new Conversation is OK")
        
        DatabaseManager.shared.conversationExists(with: email) {[weak self] result in
            guard let strongSelf = self else{ return }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    //===================== Buttons ======================
    @objc func composeHandler(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else { return }
            let currentConversations = strongSelf.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(email: result.email)
            }){
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }else{
                strongSelf.createrNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
}


extension ConversationViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = conversations[indexPath.row]
        openConversation(item)
    }
    
    func openConversation(_ item: Conversation){
        let vc = ChatViewController(with: item.otherUserEmail, id: item.id)
        vc.title = item.name
        vc.navigationItem.largeTitleDisplayMode = .never
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

        cell.updateView(image: UIImage(named:""), name: item.name, message: item.latestMessage.text)
//        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            
            DatabaseManager.shared.deleteConversation(conversationId: conversationId) {[weak self] success in
                if success{
                    self?.conversations.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            tableView.endUpdates()
        }
    }
}





