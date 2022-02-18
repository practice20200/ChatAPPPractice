//
//  ChatViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SwiftUI

class ChatViewController: MessagesViewController {

    //========= Elements ===============
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    public let otherUserEmail: String
    private let conversationID : String?
    
    private var messages = [Message]()
//    var data = MessageDataProvider.dataProvider() //will be deleted later
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("Email Error")
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photpURL: "", senderId: safeEmail, displayName: "")
    }
    
    
    init(with email: String, id: String?){
        self.conversationID = id
        self.otherUserEmail  = email
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //=============== Views =================
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
//        listenForMessages(id: <#String#>)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToButtom: true)
        }
    }
    // ================= Functions =============
    private func listenForMessages(id: String, shouldScrollToButtom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else { return }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToButtom{
                        self?.messagesCollectionView.reloadData()
                    }else{
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                }
                
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }
}

extension  ChatViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
                let messageId = createMessageId() else
        {
            print("====error: textField is empty====")
            return
        }
        
        print("Sending: \(text)")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        print("isNewConversation==============")
        if isNewConversation{
            print("isNewConversationfsdafaf")
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
               print("isNewConversation")
                if success {
                    print("message is sent successfully")
                    self?.isNewConversation = false
                } else{
                    print("failed to send a message")
                }
            }
        }else{
            guard let conversationID = conversationID, let name = self.title else { return }
            DatabaseManager.shared.sendMessage(to: conversationID, name: name ,newMessage: message) { success in

                print("!isNewConversation")
                if success {
                    print("message sent")
                } else{
                    print("failed to send")
                }
            }
        }
    }
    
    private func createMessageId() -> String? {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("let dateString = Self.dateFormatter.string(from: Date()) is nil")
            return "ddd"
            
        }
        print("GOOD")
        let safeCurrenEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        let dateString = DateFormatters.dateFormattersChatView(date: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrenEmail)_\(dateString)"
        print("created message id: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController : MessagesDataSource{
    func currentSender() -> SenderType {
        
        if let sender = selfSender {
            return sender
        }
        fatalError("SelfSender is nil, email should be cashed")
//        return Sender(photpURL: "", senderId: "-1", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return data[indexPath.section]
        return messages[indexPath.section]// will be replaced with data[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       // return message.count
        return messages.count // will be replaced with message.count
    }
    
    
}

extension ChatViewController : MessagesLayoutDelegate{
    
}

extension ChatViewController : MessagesDisplayDelegate{
    
}



//will be deleted later
//class MessageDataProvider{
//    static func dataProvider() -> [Message]{
//        var array = [Message]()
//        array.append(Message(sender: ChatViewController.selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello")))
//        array.append(Message(sender: ChatViewController.selfSender, messageId: "1", sentDate: Date(), kind: .text("hey")))
//        return array
//    }
//}

