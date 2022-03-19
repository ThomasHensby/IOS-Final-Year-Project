//
//  ChatViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 15/03/2022.
//

import UIKit
import MessageKit



//decides placement of messages depending on sender or reciever
struct Sender: SenderType{
    //var photoURL: String
    var senderId: String
    var displayName: String
}

struct Message: MessageType
{
    var sender: SenderType
    var messageId: String = ""
    var sentDate: Date
    var kind: MessageKind
}

//creates protocol for messagelist

//messageViewController implements all user interface for messagelist
class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    
    
    let currentUser = Sender(senderId: "self", displayName: "Thomas")
    let otherUser = Sender(senderId: "other", displayName: "John Smith")
    
    
    //create a variable to append messages to
    var messages = [MessageType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: currentUser, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello World")))
        messages.append(Message(sender: otherUser, messageId: "2", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hello")))
        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-86400), kind: .text("How are you?")))
        messages.append(Message(sender: otherUser, messageId: "4", sentDate: Date().addingTimeInterval(-86400), kind: .text("I'm good thank you")))
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    

}
