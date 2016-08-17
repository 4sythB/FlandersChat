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
    static let recordIDKey = "ckRecordID"
    
    var users: [CKReference]
    var threadRecordID: CKRecordID?
    var messages: [Message] = []
    
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Thread.recordTypeKey)
        record.setValue(users, forKey: Thread.usersKey)
        
        if let recordID = threadRecordID {
            let recordIDReference = CKReference(recordID: recordID, action: .None)
            record.setValue(recordIDReference, forKey: Thread.recordIDKey)
        }
        
        return record
    }
    
    init(users: [CKReference]) {
        self.users = users
    }
    
    convenience init?(record: CKRecord) {
        guard let users = record[Thread.usersKey] as? [CKReference] else { return nil }
        
        self.init(users: users)
        threadRecordID = record.recordID
    }
}