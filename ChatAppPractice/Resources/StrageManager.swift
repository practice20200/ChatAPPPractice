//
//  StrageManager.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-12.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UPloadPictureCompletion = (Result< String, Error >)  -> Void
    public func uploadProfilePicture(with data : Data, fileName: String, completion: @escaping UPloadPictureCompletion){
        storage.child("images\(fileName)").putData(data, metadata: nil, completion:{
            metadata, error in
            
            guard error == nil else {
                print("failed to upload data to firebase for picture.")
                completion(.failure(StrageErrors.failedToGetDownloadUrl))
                return
            }
            self.storage.child("image\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("failed to get download url.")
                    completion(.failure(StrageErrors.failedToGetDownloadUrl))
                    return
                            
                }
                let urlString = url.absoluteString
               print("download url returned: \(urlString)")
                completion(.success(urlString))
        })
    })
 
    }
    
    public enum StrageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }

}

