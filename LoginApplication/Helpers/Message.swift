//
//  Message.swift
//  LoginApplication
//
//  Created by Thomas Hensby on 15/03/2022.
//

import Foundation

struct Message: Identifiable, Codable {
    var id: String
    var text: String
    var recived: Bool
    var timestamp: Date
}
