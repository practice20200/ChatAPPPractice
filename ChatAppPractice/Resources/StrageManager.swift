//
//  StrageManager.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-12.
//

import Foundation
import FirebaseStorage

//Get, fetch, upload files to firebase storage
final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    private init(){}
    public typealias UPloadPictureCompletion = (Result< String, Error >)  -> Void
    
    
    // ========== Functions ==========
    public func uploadProfilePicture(with data : Data, fileName: String, completion: @escaping UPloadPictureCompletion){

        /// FileName:     images/test1_yahoooooo.picture_png
        storage.child("images/" + fileName).putData(data, metadata: nil, completion:{ [weak self]
            metadata, error in
            
            guard let strongSelf = self else { return }
            print("fileName: \(fileName)")
            guard error == nil else {
                print("failed to upload data to firebase for picture.")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            print("succeeded in uploading a picture")
            strongSelf.storage.child("images/" + fileName).downloadURL(completion: { url, error in
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
    
    public func uploadMessagePhoto(with data : Data, fileName: String, completion: @escaping UPloadPictureCompletion){

        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion:{ [weak self]
            metadata, error in
            guard let strongSelf = self else { return }
            
            print("fileName: \(fileName)")
            guard error == nil else {
                print("failed to upload data to firebase for picture.")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            print("succeeded in uploading a picture")
            strongSelf.storage.child("message_images/" + fileName).downloadURL(completion: { url, error in
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
    
    public func uploadMessageVideo(with fileUrl : URL, fileName: String, completion: @escaping UPloadPictureCompletion){

        storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil, completion:{
           [weak self] metadata, error in
            guard let strongSelf = self else { return }
            
            print("fileName: \(fileName)")
            guard error == nil else {
                print("failed to upload video file to firebase for videos.")
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            print("succeeded in uploading a picture")
            strongSelf.storage.child("message_videos/\(fileName)").downloadURL(completion: {  url, error in
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

