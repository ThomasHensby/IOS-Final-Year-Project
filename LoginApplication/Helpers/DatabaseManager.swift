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
        //make new entry
        database.child(user.safeEmail).setValue([
            "username": user.username
        ], withCompletionBlock: { error, _ in
            //make sure doesnt fail to add user
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            ///Add to collection of users
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                //var makes it mutable allowing append
                if var usersCollection = snapshot.value as? [[String:String]] {
                    //Append to user dictionary
                    let newElement = [
                        [
                            "username": user.username,
                            "email": user.safeEmail
                        ]
                    ]
                    usersCollection.append(contentsOf: newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
                else{
                    //Create array if not created before
                    let newCollection: [[String:String]] = [
                        [
                            "username": user.username,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: {error, _ in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
            })
            
        })
    }
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String:String]] else {
                completion( .failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    /* ^^ each time create user add to a dictonary of Users
    Users[
            [
                "username":
                "safe_email":
            ]
        ]
     */
}




///Structure of a user in the chat
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
