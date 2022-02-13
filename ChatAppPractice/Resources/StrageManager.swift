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

        storage.child("images/" + fileName).putData(data, metadata: nil, completion:{
            metadata, error in
            print("fileName: \(fileName)")
            guard error == nil else {
                print("failed to upload data to firebase for picture.")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            print("succeeded in uploading a picture")
            self.storage.child("images/" + fileName).downloadURL(completion: { url, error in
                guard let url = url else {
                    print("failed to get download url.")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                            
                }
                let urlString = url.absoluteString
               print("download url returned: \(urlString)")
                completion(.success(urlString))
        })
    })
 
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }

    public func downloadURL(for path: String, completion: @escaping(Result<URL, Error>) -> Void){
        storage.child(path).downloadURL { url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        }
        
        
    }
}

