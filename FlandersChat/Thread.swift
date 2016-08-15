//
//  Thread.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CloudKit

class Thread {
    
    static let recordTypeKey = "thread"
    static let usersKey = "users"
    static let messagesKey = "messages"
    
    var users: [CKRecord]
    var messages: [Message]
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Thread.recordTypeKey)
        record.setValue(users, forKey: Thread.usersKey)
        
        return record
    }
    
    init(users: [CKRecord], messages: [Message]) {
        self.users = users
        self.messages = messages
    }
    
    convenience init?(record: CKRecord) {
        guard let users = record[Thread.usersKey] as? [CKRecord],
            messages = record[Thread.messagesKey] as? [Message] else { return nil }
        
        self.init(users: users, messages: messages)
    }
}