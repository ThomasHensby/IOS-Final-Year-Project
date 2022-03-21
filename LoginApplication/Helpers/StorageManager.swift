//
//  StorageManager.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 20/03/2022.
//

import Foundation
import FirebaseStorage
import FirebaseMLModelDownloader


final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    ///Uploads photo to firebase storage and returns completion with url string to download
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else{
                //failed
                print("failed to upload data to firebase for picture")
                completion(.failure(storageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                guard let url = url else{
                    print("failed to get Download URL")
                    completion(.failure(storageErrors.failedTogetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
    
    public enum storageErrors: Error {
        case failedToUpload
        case failedTogetDownloadUrl
    }
    
    
}
