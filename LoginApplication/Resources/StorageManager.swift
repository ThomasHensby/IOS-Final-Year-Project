//
//  StorageManager.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 20/03/2022.
//

import Foundation
import FirebaseStorage
import FirebaseMLModelDownloader

///To get, getch and upload files to firebase storage
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
    
    ///download URL for the photo on the account
    //escaping allows escape of asyncronous  execution block
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void)
    {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else {
                completion(.failure(storageErrors.failedTogetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
    
    
}
