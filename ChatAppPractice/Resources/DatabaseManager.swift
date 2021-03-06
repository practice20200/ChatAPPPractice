//
//  databaseManager.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-08.
//

import Foundation
import FirebaseDatabase
import UIKit
import MessageKit
import CoreLocation

/// Manage to read and write data in realtime firebase
final class DatabaseManager {
    public static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func safeEmail(email: String) -> String{
    
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}


extension DatabaseManager {
    ///Get dictionary node data in child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public func deleteConversation(conversationID: String, completion: @escaping(Bool) -> Void){
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(email: email)


        print("")
        let ref = database.child("\(safeEmail)/conversations")
        ref.observeSingleEvent(of: .value){ snapshot in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                       id == conversationID {
                        print("failed to write new conversation array")
                        break
                    }
                    positionToRemove += 1

                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock:  { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to write new conversation array")
                        return
                    }
                    print("deleted conversation successfully")
                    completion(true)
                })
            }

        }
    }

    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void){
        let safeRecipientEmail = DatabaseManager.safeEmail(email: targetRecipientEmail)
        guard  let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail =  DatabaseManager.safeEmail(email: senderEmail)

        database.child("\(safeRecipientEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
            guard let collection = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            if let conversation = collection.first(where: {
                guard let targetSenderEmail = $0["other_user_email"] as? String else {
                    return false
                }
                return safeSenderEmail == targetSenderEmail
            }){
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
            return
        }
    }

    
}
    

extension DatabaseManager{
    
    ///Checkif user already exists
    ///-email: email to be checked
    ///-completion: Async closure to return with result
    
    public func userExists(with email: String, completion: @escaping((Bool) -> Void)){
        
        // to avoid confliction from invalid Path with some symbols(".", "@"......)
        let safeEmail = DatabaseManager.safeEmail(email: email)

        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                print("This user doesn't exsit. You can create a new user.")
                return
            }
            completion(true)
        })
    }
    
    public func insertUser(with user : ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue(["name": user.userName]) {[weak self] error, _ in
            guard let strongSelf = self else { return }
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            strongSelf.database.child("users").observeSingleEvent(of: .value) {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //append to user dictionary
                    let newElement = [
                        "name": user.userName,
                         "email": user.email
                    ]
                    usersCollection.append(newElement)
                    strongSelf.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }}else{
                    //create to user dictionary
                    let newCollection: [[String: String]] = [
                        ["name": user.userName,
                         "email": user.email]
                    ]
                    strongSelf.database.child("users").setValue(newCollection) { error, _ in
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
    
    ///Get all user information
    ///--users [
    ///         "name" :   ,
    ///          "safeEmail" :
    ///       ]
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            print("Succeeded in recieving user's list")
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error{
        case failedToFetch
        
        public var localizedDescription: String{
            switch self {
                case .failedToFetch:
                    return "This means blah failed"
            }
        }
    }
}



extension DatabaseManager {
    // Create a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String ,firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                print("check1-createNewConversation")
                return
        }
        
        
        print("check2  Name:   \(currentName)")
        print("check2  Name:   \(name)")
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
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
                    "latest_message" : [
                        "date" : dateString,
                        "message": message,
                        "is_read": false
                    ]
                ]
            
            let recipient_newConversationData : [String: Any] = [
                "id" : conversationID,
                "other_user_email" : safeEmail,
                "name": currentName,
                "latest_message" : [
                    "date" : dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
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
            "messages" : [
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
                guard let conversationID = dictionary ["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          print("Conversation model nil : getAllConversation function")
                          return nil }

                print("Success reading Conversation data")
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationID, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
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
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString)
                else {
                          return nil
                      }
                
                var kind: MessageKind?
                if type == "photo"{
                    guard let imageUrl = URL(string: content),
                          let placeHolder = UIImage(systemName: "plus") else { return nil }
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300,height: 300))
                    kind = .photo(media)
                }else if type == "video"{
                    guard let videoUrl = URL(string: content),
                         let placeHolder = UIImage(systemName: "play.rectangle") else { return nil }
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeHolder, size: CGSize(width: 300,height: 300))
                         kind = .video(media)
                }else if type == "location"{
                    let locationComponents = content.components(separatedBy: ",")
                   guard  let longitude = Double(locationComponents[0]),
                          let latitude = Double(locationComponents[1]) else { return nil}
                    print("Rendering location: long = \(longitude) , lat = \(latitude)")
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: CGSize(width: 300,height: 300))
                         kind = .location(location)
                }
                else{
                    kind = .text(content)
                }
                
                guard let finalKind = kind else{
                    return nil
                }

                let sender = Sender(photpURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: finalKind)
                
            }
            completion(.success(messages))
        })
        
    }
    
    //Send a message with target conversation adn message
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String ,newMessage: Message, completion: @escaping (Bool) -> Void){
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        let currentEmail = DatabaseManager.safeEmail(email: myEmail)
//        DatabaseManager.shared.sendMessage(to: self.conversationID, message: message) { @escaping: (Bool) ->  in
            self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                 
                guard let strongSelf = self else{
                    return
                }
                guard var currentMessages = snapshot.value as? [[String: Any]] else {
                    completion(false)
                    return
                }
                
                let messageDate = newMessage.sentDate
                var message = ""
                switch newMessage.kind{
                   
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(let mediaItem):
                    if let targetUrlString = mediaItem.url?.absoluteString{
                        message = targetUrlString
                    }
                    
                    break
                case .video(let mediaItem):
                    if let targetUrlString = mediaItem.url?.absoluteString{
                        message = targetUrlString
                    }
                    break
                case .location(let locationData):
                    let location = locationData.location
                    message = "\(location.coordinate.longitude),\(location.coordinate.latitude)"
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
                let newMessageEntry: [String: Any] = [
                    "name": name,
                    "id": newMessage.messageId,
                    "type": newMessage.kind.messageKindString,
                    "content":message,
                    "date":  DateFormatters.dateFormattersChatView(date: messageDate),
                    "sender_email": currentUserEmail,
                    "is_read" : false
                ]
                currentMessages.append(newMessageEntry)
                strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                        var databaseEntryConversations = [[String: Any]]()
                        let updatedValue : [String: Any] = [
                            "date": DateFormatters.dateFormattersChatView(date: Date()),
                            "is_read": false,
                            "message": message
                        ]
                        if var currentUserConversations = snapshot.value as? [[String: Any]] {
                            var targetConversation : [String: Any]?
                            var position = 0
                            for conversationDictionary in currentUserConversations {
                                if let currentID = conversationDictionary["id"] as? String, currentID == conversation {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            
                            if var  targetConversation = targetConversation {
                                targetConversation["latest_message"] = updatedValue
                                currentUserConversations[position] = targetConversation
                                databaseEntryConversations = currentUserConversations
                            }else{
                                let newConversationData : [String: Any] = [
                                    "id" : conversation,
                                    "other_user_email" : DatabaseManager.safeEmail(email: otherUserEmail),
                                    "name": name,
                                    "latest_message" : updatedValue
                                       
                                ]
                                currentUserConversations.append(newConversationData)
                                databaseEntryConversations = currentUserConversations
                            }
                        }else{
                            let newConversationData : [String: Any] = [
                                "id" : conversation,
                                "other_user_email" : DatabaseManager.safeEmail(email: otherUserEmail),
                                "name": name,
                                "latest_message" : updatedValue
                                   
                            ]
                            
                            databaseEntryConversations = [
                                   newConversationData
                            ]
                        }

                        
                        //Recipient side : LatestMessage
                        strongSelf.database.child("\(currentEmail)/conversations").setValue(databaseEntryConversations) { error , _ in
                            guard error == nil else{
                                completion(false)
                                return
                            }
                            
                            strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapshot in
                                let updatedValue : [String: Any] = [
                                    "date": DateFormatters.dateFormattersChatView(date: Date()),
                                    "is_read": false,
                                    "message": message
                                ]
                                var databaseEntryConversations = [[String: Any]]()
                                guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else{
                                    return
                                }
                                if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                   
                                    var targetConversation : [String: Any]?
                                    var position = 0
                                    for conversationDictionary in otherUserConversations {
                                        if let currentID = conversationDictionary["id"] as? String, currentID == conversation {
                
                                            targetConversation = conversationDictionary
                                            break
                                        }
                                        position += 1
                                        
                                    }
                                    
                                    if var targetConversation = targetConversation {
                                        targetConversation["latest_message"] = updatedValue
                                        otherUserConversations[position] = targetConversation
                                        databaseEntryConversations = otherUserConversations
                                    }else{
                                        let newConversationData : [String: Any] = [
                                            "id" : conversation,
                                            "other_user_email" : DatabaseManager.safeEmail(email: currentUserEmail),
                                            "name": currentName,
                                            "latest_message" : updatedValue
                                               
                                        ]
                                        otherUserConversations.append(newConversationData)
                                        databaseEntryConversations = otherUserConversations
                                    }
                                  
                                    
                                }else{
                                    let newConversationData : [String: Any] = [
                                        "id" : conversation,
                                        "other_user_email" : DatabaseManager.safeEmail(email: currentUserEmail),
                                        "name": name,
                                        "latest_message" : updatedValue
                                           
                                    ]
                                    databaseEntryConversations = [ newConversationData ]
                                }

                                strongSelf.database.child("\(otherUserEmail)/conversations").setValue(databaseEntryConversations) { error , _ in
                                    guard error == nil else{
                                        completion(false)
                                        return
                                    }
                                    completion(true)
                            
                                }
                            }
                        }
                    }
                }
            })
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
//    return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
//}
//completion(.success(conversations))
