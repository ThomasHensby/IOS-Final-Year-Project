//
//  DatabaseManager.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 17/03/2022.
//

import Foundation
import FirebaseDatabase
import FirebaseMLModelDownloader


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

///Sending messages / conversations
extension DatabaseManager {
    
    /*
     
     conversation_id {
        "messages": [
            {
                "id": string,
                "type": text,
                "content": String,
                "date": date(),
                "sender_email": String,
                "isRead": true/false
            }
        ]
     }
     
     
    conversation[
            [
                "conversation_id":
                "other_user_email":
                "latest_message": => {
                "date": date()
                "latest_message": "message"
                "is_read": true/false
            ]
        ]
     */
    
    ///Creates a new converation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: {snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = CalendarHelper().timeString(date: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .custom(_):
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            }
            
            var conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id" : conversationID,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //Conversation arrary exists for current user
                //you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
            else {
                // conversation array doesn not exist
                //create array
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                    
                })
            }
            
        })
        
        
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        conversation_id {
//               {
//                   "id": string,
//                   "type": text,
//                   "content": String,
//                   "date": date(),
//                   "sender_email": String,
//                   "isRead": true/false
//               }
//            }
        let messageDate = firstMessage.sentDate
        let dateString = CalendarHelper().timeString(date: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .custom(_):
            break
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(email: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "isRead": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    
    /// Fetches and returns all converstations for the user with passed in email
    public func getAllConversation(for email: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void){
        
    }
    ///Sends a message with a target conversaton and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void)
    {
        
    }
    
}


///Structure of a user in the chat
struct ChatAppUser {
    let username: String
    let email: String

    
    var safeEmail: String{
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
