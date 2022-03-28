//
//  ChatModels.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 28/03/2022.
//

import Foundation
import CoreLocation
import MessageKit

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


extension MessageKind {
    var messageKindString: String{
        switch self{
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "locatio "
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}
