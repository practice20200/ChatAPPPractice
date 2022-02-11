//
//  ChatViewController.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {

    private var message = [Message]()
    var data = MessageDataProvider.dataProvider() //will be deleted later
    static let selfSender = Sender(photpURL: "", senderId: "1", displayName: "Brian")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
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

