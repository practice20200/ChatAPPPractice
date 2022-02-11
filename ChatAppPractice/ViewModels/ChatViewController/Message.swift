//
//  Message.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-11.
//

import Foundation
import MessageKit
struct Message : MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
