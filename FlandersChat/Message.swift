//
//  Message.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CloudKit

class Message {
    
    static let recordTypeKey = "message"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let senderKey = "sender"
    static let conversationKey = "conversation"
    
    let text: String
    let timestamp: NSDate
    let sender: CKReference
    let conversation: CKReference
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Message.recordTypeKey)
        record.setValue(text, forKey: Message.textKey)
        record.setValue(timestamp, forKey: Message.timestampKey)
        record.setValue(sender, forKey: Message.senderKey)
        record.setValue(conversation, forKey: Message.conversationKey)
        
        return record
    }
    
    init(text: String, timestamp: NSDate = NSDate(), sender: CKReference, conversation: CKReference) {
        self.text = text
        self.timestamp = timestamp
        self.sender = sender
        self.conversation = conversation
    }
    
    convenience init?(record: CKRecord) {
        guard let text = record[Message.textKey] as? String,
            timestamp = record[Message.timestampKey] as? NSDate,
            sender = record[Message.senderKey] as? CKReference,
            conversation = record[Message.conversationKey] as? CKReference else { return nil }
        
        self.init(text: text, timestamp: timestamp, sender: sender, conversation: conversation)
    }
}