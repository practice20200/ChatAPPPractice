//
//  databaseManager.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-08.
//

import Foundation
import FirebaseDatabase
import UIKit

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func safeEmail(email: String) -> String{
    var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


extension DatabaseManager{
    
    public func userExists(with email: String, completion: @escaping((Bool) -> Void)){
        
        // to avoid confliction from invalid Path with some symbols(".", "@"......)
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                print("Error: this user already exists.")
                return
            }
            completion(true)
        })
       
    }
    
    public func insertUser(with user : ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue(["user name": user.userName]) { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) {[weak self] snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //append to user dictionary
                    let newElement = [
                        "name": user.userName,
                         "email": user.email
                    ]
                    usersCollection.append(newElement)
                    self?.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                }else{
                    //create to user dictionary
                    let newCollection: [[String: String]] = [
                        ["name": user.userName,
                         "email": user.email]
                    ]
                    self?.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
            
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
    }
    
}



extension DatabaseManager {
    // Create a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String ,firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("check1")
            return
        }
        
        print("check2")
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("check3")
                print("user is not found")
                return
            }
            print("check4")
            let messageDate = firstMessage.sentDate
            var message = ""
            let dateString = DateFormatters.dateFormattersChatView(date: messageDate)

            switch firstMessage.kind{
               
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
                let conversationID = "conversation_\(firstMessage.messageId)"
                
                let newConversationData : [String: Any] = [
                    "id" : conversationID,
                    "other_user_email" : otherUserEmail,
                    "name": name,
                    "last_message" : [
                        "date" : dateString,
                        "message": message,
                        "is_read": false
                    ]
                ]
            
            let recipient_newConversationData : [String: Any] = [
                "id" : conversationID,
                "other_user_email" : safeEmail,
                "name": "Self",
                "last_message" : [
                    "date" : dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationID)
                }else{
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            print("check5")
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        print("check6")
                        return
                    }
                    print("check7")
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    completion(true)
                    
                }
            }else {
                print("check8")
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name:name,conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                    completion(true)
                }
            }
        }
        print("check9")
    }
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping(Bool) -> Void){
        
        let messageDate = firstMessage.sentDate
        var message = ""
        switch firstMessage.kind{
           
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(email: myEmail)
        
        let collectionMessage: [String: Any] = [
            "name": name,
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content":message,
            "date":  DateFormatters.dateFormattersChatView(date: messageDate),
            "sender_email": currentUserEmail,
            "is_read" : false
        ]
        
        let value : [String: Any] = [
            "message" : [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    // Fetch and return all conversation for user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap { dictionary in
                guard let conversationId = dictionary ["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          print("no")
                          return nil }

                print("Success reading Conversation data")
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, lastestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        })
        
    }
    
    // Get all message for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<[Message], Error>) -> Void){
        
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap { dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String
                      // let date = DateFormatters.dateFormattersChatView(date: Date())
                else {
                          return nil
                      }
                let sender = Sender(photpURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: Date(), kind: .text(content))
                
            }
            completion(.success(messages))
        })
        
    }
    
    //Send a message with target conversation adn message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void){
        
    }
}



struct ChatAppUser{
    var userName: String
    var email: String
    
    
    var safeEmail: String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureURL: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    
}


//let conversations: [Conversation] = value.compactMap { dictionary in
//    guard let conversationId = dictionary ["id"] as? String,
//          let name = dictionary["name"] as? String,
//          let otherUserEmail = dictionary["other_user_email"] as? String,
//          let latestMessage = dictionary["latest_message"] as? [String: Any],
//          let date = latestMessage["date"] as? String,
//          let message = latestMessage["message"] as? String,
//          let isRead = latestMessage["is_read"] as? Bool else {
//              print("no")
//              return nil }
//
//    print("Success reading Conversation data")
//    let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
//    return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, lastestMessage: latestMessageObject)
//}
//completion(.success(conversations))
