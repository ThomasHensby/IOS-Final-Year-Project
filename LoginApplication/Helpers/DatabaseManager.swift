//
//  DatabaseManager.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 17/03/2022.
//

import Foundation
import FirebaseDatabase


final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database(url: "https://game-helper-8d79a-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    
    
    ///Test to see if inputting data in realtime database
    //public func test(){
    //    database.child("foo").setValue(["something" : true])
    //}
    
    //need safe emails as firebase does not accept @ and . chars
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

//ACCOUNT MANAGEMENT
extension DatabaseManager{
    
    
    public func userEmailExists(with email: String,
                                completion: @escaping ((Bool) -> Void))
    {
        //Changing the email as not allowed . or @ in firebase
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        ///Querying database to see if email has been input before
        database.child(safeEmail).observeSingleEvent(of: .value, with:  { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "username": user.username
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users")
            completion(true)
        })
    }
}

struct ChatAppUser {
    let username: String
    let email: String
    //let profilePic
    
    var safeEmail: String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
