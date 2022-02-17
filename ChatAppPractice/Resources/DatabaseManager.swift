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
    static func sefeEmail(email: String) -> String{
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
        database.child(user.sefeEmail).setValue(["user name": user.userName]) { error, _ in
            guard error == nil else{
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]]{
                    //append to user dictionary
                    let newElement = [
                        "name": user.userName,
                         "email": user.email
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection) { error, _ in
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
                    self.database.child("users").setValue(newCollection) { error, _ in
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
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
    }
    
    // Fetch and return all conversation for user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    
    // Get all message for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping(Result<String, Error>) -> Void){
        
    }
    
    //Send a message with target conversation adn message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void){
        
    }
}


struct ChatAppUser{
    var userName: String
    var email: String
    
    
    var sefeEmail: String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureURL: String {
        return "\(sefeEmail)_profile_picture.png"
    }
    
    
}
