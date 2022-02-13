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
            completion(true)
        }
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
