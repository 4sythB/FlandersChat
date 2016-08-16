//
//  MessageController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CloudKit

class MessagesController {
    
    let cloudKitManager = CloudKitManager()
    
    var messages: [Message] = []
    
    func saveMessage(message: Message, completion: () -> Void) {
        
        let messageRecord = message.cloudKitRecord
        
        cloudKitManager.saveRecord(messageRecord) { (record, error) in
            if error != nil {
                print("Error saving message to cloudKit: \(error?.localizedDescription)")
                completion()
            }
            self.messages.append(message)
            completion()
        }
    }
    
    func fetchMessages(thread: Thread, completion: () -> Void) {
        
        let threadRecordID = thread.cloudKitRecord.recordID
        
        let predicate = NSPredicate(format: "thread == %@", threadRecordID)
        
        cloudKitManager.fetchRecordsWithType(Message.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
            //
        }) { (records, error) in
            if error != nil {
                print("Error fetching messages: \(error?.localizedDescription)")
                completion()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    guard let records = records else { completion(); return }
                    
                    for record in records {
                        guard let message = Message(record: record) else { completion(); return }
                        self.messages.append(message)
                    }
                    completion()
                }
            }
        }
    }
}