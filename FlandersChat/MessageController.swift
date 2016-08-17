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
    static let sharedController = MessagesController()
    
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
        
        guard let threadRecordID = thread.threadRecordID else { completion(); return }
        
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
                        thread.messages.append(message)
                    }
                    completion()
                }
            }
        }
    }
    
    func fetchSenderForMessage(message: Message, completion: () -> Void) {
        
        cloudKitManager.fetchRecordWithID(message.sender.recordID) { (record, error) in
            if error != nil {
                print("Error fetching sender of message: \(error?.localizedDescription)")
                completion()
            } else {
                guard let record = record, user = User(record: record) else { return }
                message.senderUser = user
                completion()
            }
        }
    }
}








