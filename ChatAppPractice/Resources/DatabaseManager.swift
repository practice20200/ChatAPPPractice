//
//  databaseManager.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-08.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()

}


extension DatabaseManager{
    
    public func userExists(with email: String, completion: @escaping((Bool) -> Void)){
        
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                print("Error: this user already exists.")
                return
            }
            completion(true)
        })
       
    }
    
    public func insertUser(with user : ChatAppUser){
        database.child(user.email).setValue(["user name": user.userName])
    }
    
    
}


struct ChatAppUser{
    var userName: String
    var email: String
    //var profilePictureURL: String
}
