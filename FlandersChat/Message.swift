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
    static let threadKey = "thread"
    
    let text: String
    let timestamp: NSDate
    let sender: CKReference
    let thread: CKReference
    
    var senderUser: User?
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Message.recordTypeKey)
        record.setValue(text, forKey: Message.textKey)
        record.setValue(timestamp, forKey: Message.timestampKey)
        record.setValue(sender, forKey: Message.senderKey)
        record.setValue(thread, forKey: Message.threadKey)
        
        return record
    }
    
    init(text: String, timestamp: NSDate = NSDate(), sender: CKReference, thread: CKReference) {
        self.text = text
        self.timestamp = timestamp
        self.sender = sender
        self.thread = thread
    }
    
    convenience init?(record: CKRecord) {
        guard let text = record[Message.textKey] as? String,
            timestamp = record[Message.timestampKey] as? NSDate,
            sender = record[Message.senderKey] as? CKReference,
            thread = record[Message.threadKey] as? CKReference else { return nil }
        
        self.init(text: text, timestamp: timestamp, sender: sender, thread: thread)
    }
}