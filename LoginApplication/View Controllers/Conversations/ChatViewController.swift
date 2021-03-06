//
//  ChatViewController.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 15/03/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView




//creates protocol for messagelist

//messageViewController implements all user interface for messagelist
class ChatViewController: MessagesViewController{
    
    public let otherUserEmail: String
    private let conversationId: String?
    
    public var isNewConversation = false
    //create a variable to append messages to
    var messages = [Message]()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
    }
    
    
    init(with email: String, id: String?) {
        self.conversationId = id
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
    }
    ///checks to see if messages are coming in
    private func listenForMessages(id: String, shouldScrollToBottom: Bool){
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async{
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case.failure(let error):
                print("Failed to get messages: \(error)")
            }
            
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId{
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
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
        
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        //Send Message
        if isNewConversation {
            //create convo in database
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "username", firstMessage: message, completion: { [weak self] success in
                if success{
                    print("message sent")
                    self?.isNewConversation = false
                }
                else{
                    print("Failed to send")
                }
            })
        }
        else{
            //append to existing convo
            guard let conversationId = conversationId, let name = self.title else{
                return
            }
            DatabaseManager.shared.sendMessage(to: conversationId, name: name, otherUserEmail: otherUserEmail, newMessage: message, completion: { success in
                if success{
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            })
        }
        
    }
    
    ///Create a unique ID
    private func createMessageId() -> String?{
        //date, otherUserEmail, senderEmail, random int
        let dateString = CalendarHelper.dateFormatter.string(from: Date())
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") else {
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(email: currentUserEmail as! String)
        
        let newID = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
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
     
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    

}
