//
//  ChatViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    
    public var isNewConversation = false
    public let otherUserEmail: String
    private var message = [Message]()
//    var data = MessageDataProvider.dataProvider() //will be deleted later
    private var selfSender : Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        return Sender(photpURL: "", senderId: email, displayName: "")
    }
    
    init(with email: String){
        self.otherUserEmail  = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }

}

extension  ChatViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: "", with: " ").isEmpty,
              let messageId = createMessageId(),
              let selfSender = self.selfSender
        else {
            print("====error: textField is empty====")
            return
        }
        
        print("Sending: \(text)")
        
        if isNewConversation{
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message) { success in
                if success {
                    print("message")
                }
            }
        }else{
            
        }
    }
    
    private func createMessageId() -> String? {
        let dateString = DateFormatters.dateFormattersChatView(date: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else { return nil}
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
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
        return Sender(photpURL: "", senderId: "-1", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return data[indexPath.section]
        return message[indexPath.section]// will be replaced with data[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       // return message.count
        return message.count // will be replaced with message.count
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

