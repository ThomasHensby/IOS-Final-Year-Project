//
//  DatabaseManager.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 17/03/2022.
//

import Foundation
import FirebaseDatabase
//import FirebaseMLModelDownloader

/// Manager object to read and write data to real time firbase database
final class DatabaseManager {
    
    /// Shared intance of class
    static let shared = DatabaseManager()
    
    ///Conection to the Firebase NOSQL server - Due to it being a europe server have to send in link
    private let database = Database.database(url: "https://game-helper-8d79a-default-rtdb.europe-west1.firebasedatabase.app/").reference()
    
    
   
}

///Extension built for general function where database manager is needed
extension DatabaseManager{
    
    //need safe emails as firebase does not accept @ and . chars
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    ///Generic lookup feature for database when path passed to it will return dictonary node
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void)
    {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

//ACCOUNT MANAGEMENT
extension DatabaseManager{
    
    /// Checks if user exists for given email address
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
    
    ///Gets all usernames from database
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

/// Sending events to database
extension DatabaseManager{
    
    
    
    /*
    events[
            [
                "Event_id": String
                "Name": name of event
                "date": date()
                "invite": True/false
                "inviteWith": String
                "from": String
            ]
        ]
    */
    public func createNewEvent(eventId: String, dateOfEvent: String, otherUserEmail: String, String invite: Bool, nameOfEvent: String, completion: @escaping (Bool) -> Void)
    {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        guard let currentName = UserDefaults.standard.value(forKey: "username") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let newEventData: [String: Any] = [
                "eventId" : eventId,
                "date": dateOfEvent,
                "name": nameOfEvent,
                "otherUserEmail": otherUserEmail,
                "invite": invite,
                "from": safeEmail
            ]
            
            let recipientEventData: [String: Any] = [
                "eventId" : eventId,
                "date": dateOfEvent,
                "name": nameOfEvent,
                "otherUserEmail": safeEmail,
                "invite": invite,
                "from" : safeEmail
            ]
            
            //update the recipient events entry
            self?.database.child("\(otherUserEmail)/events").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var events = snapshot.value as? [[String:Any]] {
                    //append
                    events.append(recipientEventData)
                    self?.database.child("\(otherUserEmail)/events").setValue(events)
                }
                else{
                    // create
                    self?.database.child("\(otherUserEmail)/events").setValue([recipientEventData])
                }
            })
            
            //Update current event
            if var events = userNode["events"] as? [[String: Any]] {
                //events arrary exists for current user
                //you should append
                events.append(newEventData)
                userNode["events"] = events
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                })
            }
            else {
                // events array doesn not exist
                //create array
                userNode["events"] = [
                    newEventData
                ]
                ref.setValue(userNode, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                })
            }
        })
    }
    
    
    
    public func getAllEvents( completion: @escaping (Result<[Event], Error>) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        
        database.child("\(safeEmail)/events").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let events: [Event] = value.compactMap({ dictionary in
                guard let eventId = dictionary["eventId"] as? String,
                      let dateOfEvent = dictionary["date"] as? String,
                      let nameOfEvent = dictionary["name"] as? String,
                      let invite = dictionary["invite"] as? Bool,
                      let initeWith = dictionary["otherUserEmail"]as? String,
                      let from = dictionary["from"] as? String else{
                          return nil
                      }
                return Event(eventId: eventId, name: nameOfEvent, date: dateOfEvent, invite: invite, inviteWith: initeWith, from:from)
                      
            })
            completion(.success(events))
        })
    }
    
    public func deleteEvent(email: String, eventId: String, completion: @escaping ((Bool) -> Void)){
        let ref = database.child("\(email)/events")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if var events = snapshot.value as? [[String:Any]]{
                var positionToRemove = 0
                for event in events {
                    if let id = event["eventId"] as? String,
                       id == eventId{
                        break
                    }
                    positionToRemove += 1
                }
                
                events.remove(at: positionToRemove)
                ref.setValue(events, withCompletionBlock: { error, _ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
                
        })
            
    }
    
    public func changeInvite(eventId: String, otherUserEmail: String, completion: @escaping ((Bool) -> Void)) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)/events")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let events = snapshot.value as? [[String:Any]]{
                var positionToChange = 0
                for event in events {
                    if let id = event["eventId"] as? String,
                       id == eventId{
                        break
                    }
                    positionToChange += 1
                }
                self.database.child("\(safeEmail)/events/\(positionToChange)").updateChildValues(["invite": false])
            }
        })
        let originalRef = self.database.child("\(otherUserEmail)/events")
        originalRef.observeSingleEvent(of: .value, with: { snapshot in
            if let events = snapshot.value as? [[String:Any]]{
                var positionToChange = 0
                for event in events {
                    if let id = event["eventId"] as? String,
                       id == eventId{
                        break
                    }
                    positionToChange += 1
                }
                self.database.child("\(otherUserEmail)/events/\(positionToChange)").updateChildValues(["invite": false] )
            }
        })
    
    }
    
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
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        let currentName = UserDefaults.standard.value(forKey: "username") as? String else{
            return
        }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = CalendarHelper.dateFormatter.string(from: messageDate)
            
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
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id" : conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            
            
            let recipient_newConversationData: [String: Any] = [
                "id" : conversationID,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            //update the recipient conversation entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String:Any]] {
                    //append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
                else{
                    // create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            //Update current User Conversation entry
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
                    self?.finishCreatingConversation(name: name,
                                                    conversationID: conversationID,
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
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                    
                })
            }
            
        })
        
        
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
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
        let dateString = CalendarHelper.dateFormatter.string(from: messageDate)
        
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
            "isRead": false,
            "name": name
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
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void){
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                          return nil
                      }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
                        
            })
            
            completion(.success(conversations))
        })
    }
    
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void){
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      //if change date make sure to redo this
                      let dateString = dictionary["date"] as? String,
                      let date = CalendarHelper.dateFormatter.date(from: dateString) else{
                          return nil
                      }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: .text(content))
                        
            })
            
            completion(.success(messages))
        })
    }
    ///Sends a message with a target conversaton and message
    public func sendMessage(to conversation: String, name: String, otherUserEmail: String, newMessage: Message, completion: @escaping (Bool) -> Void)
    {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentEmail = DatabaseManager.safeEmail(email: myEmail)
        //Add new message to messages
        //update sender latest message
        //update recipient latest message
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else{
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = CalendarHelper.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
                
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
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "isRead": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else{
                    completion(false)
                    return
                }
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else{
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation : [String: Any]?
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations{
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation{
                            targetConversation = conversationDictionary
                            
                            break
                        }
                        position += 1
                        
                    }
                    targetConversation?["latest_message"] =  updatedValue
                    guard let finalConversation = targetConversation else{
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: {error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //update latest message for recipient
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else{
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            
                            var targetConversation : [String: Any]?
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations{
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversation{
                                    targetConversation = conversationDictionary
                                    
                                    break
                                }
                                position += 1
                                
                            }
                            targetConversation?["latest_message"] =  updatedValue
                            guard let finalConversation = targetConversation else{
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: {error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
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
