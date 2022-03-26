//
//  ChatViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 15/03/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView



//decides placement of messages depending on sender or reciever
struct Sender: SenderType{
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

struct Message: MessageType
{
    public var sender: SenderType
    public var messageId: String = ""
    public var sentDate: Date
    public var kind: MessageKind
}

//creates protocol for messagelist

//messageViewController implements all user interface for messagelist
class ChatViewController: MessagesViewController{
    
    public let otherUserEmail: String
    
    public var isNewConversation = false
    
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(photoURL: "", senderId: email, displayName: "John Smith")
    }

    //create a variable to append messages to
    var messages = [MessageType]()
    
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else{
                  return
        }
        print("sending:  \(text)")
        
        //Send Message
        if isNewConversation {
            //create convo in database
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, firstMessage: message, completion: { success in
                if success{
                    print("message sent")
                }
                else{
                    print("Failed to send")
                }
                
                
            })
        }
        else{
            //append to existing convo
        }
        
    }
    
    ///Create a unique ID
    private func createMessageId() -> String?{
        //date, otherUserEmail, senderEmail, random int
        let dateString = CalendarHelper().timeString(date: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        let newID = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        
        return newID
    }

}

///Extension for each users messages
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("self sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    

}
