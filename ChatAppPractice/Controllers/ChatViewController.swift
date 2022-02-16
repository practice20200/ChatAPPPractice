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
    var data = MessageDataProvider.dataProvider() //will be deleted later
    static let selfSender = Sender(photpURL: "", senderId: "1", displayName: "Brian")
    
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

}

extension  ChatViewController : InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard text.replacingOccurrences(of: " ", with: " ").isEmpty else {
            return
        }
        
        if isNewConversation{
            
        }else{
            
        }
    }
}

extension ChatViewController : MessagesDataSource{
    func currentSender() -> SenderType {
        return ChatViewController.selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return data[indexPath.section]
        return data[indexPath.section]// will be replaced with data[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
       // return message.count
        return data.count // will be replaced with message.count
    }
    
    
}

extension ChatViewController : MessagesLayoutDelegate{
    
}

extension ChatViewController : MessagesDisplayDelegate{
    
}



//will be deleted later
class MessageDataProvider{
    static func dataProvider() -> [Message]{
        var array = [Message]()
        array.append(Message(sender: ChatViewController.selfSender, messageId: "1", sentDate: Date(), kind: .text("Hello")))
        array.append(Message(sender: ChatViewController.selfSender, messageId: "1", sentDate: Date(), kind: .text("hey")))
        return array
    }
}

