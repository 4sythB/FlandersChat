//
//  ThreadController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CloudKit

class ThreadController {
    
    static let sharedController = ThreadController()
    let cloudKitManager = CloudKitManager()
    
    var threads: [Thread] = []
    var sortedThreads: [Thread] {
        return threads.sort({ $0.sortedMessages.last?.timestamp.timeIntervalSince1970 > $1.sortedMessages.last?.timestamp.timeIntervalSince1970 })
    }
    var usersInThreads: [User] = []
    
    // MARK: - Create new thread
    
    func createNewThread(users: [CKReference], completion: (thread: Thread) -> Void) {
        
        let thread = Thread(users: users)
        let threadRecord = thread.cloudKitRecord
        
        threads.append(thread)
        
        cloudKitManager.saveRecord(threadRecord) { (record, error) in
            if error != nil {
                print("Error saving new thread to cloudKit: \(error?.localizedDescription)")
                completion(thread: thread)
            }
            guard let record = record else { return }
            thread.threadRecordID = record.recordID
            completion(thread: thread)
        }
    }
    
    init() {
        subscribeToNewThreads()
    }
    
    // MARK: - Fetch from CloudKit
    
    func fetchThreadsForCurrentUser(completion: (threads: [Thread]?) -> Void) {
        
        guard let reference = UserController.sharedController.currentUserReference else { completion(threads: []); return }
        let predicate = NSPredicate(format: "users CONTAINS %@", reference)
        
        cloudKitManager.fetchRecordsWithType(Thread.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
            //
        }) { (records, error) in
            if error != nil {
                print("Error fetching threads for current user: \(error?.localizedDescription)")
                completion(threads: [])
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    guard let records = records else {
                        print("Records are nil")
                        completion(threads: [])
                        return
                    }
                    var threadsArray: [Thread] = []
                    for record in records {
                        guard let thread = Thread(record: record) else { completion(threads: []); return }
                        self.threads.append(thread)
                        threadsArray.append(thread)
                    }
                    completion(threads: threadsArray)
                }
            }
        }
    }
    
    func fetchUsersInThread(thread: Thread, completion: (() -> Void)? = nil) {
        
        for user in thread.users {
            cloudKitManager.fetchRecordWithID(user.recordID, completion: { (record, error) in
                if error != nil {
                    print("Error fetching users for thread: \(error?.localizedDescription)")
                    completion?()
                } else {
                    guard let userRecord = record else { completion?(); return }
                    if userRecord.recordID != UserController.sharedController.currentUserRecordID {
                        guard let fetchedUser = User(record: userRecord) else { completion?(); return }
                        thread.userz.append(fetchedUser)
                        completion?()
                    }
                }
            })
        }
    }
    
    // MARK: - Subscriptions
    
    func subscribeToNewThreads(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
        
        guard let currentUserID = UserController.sharedController.currentUserRecordID else { return }
        
        let predicate = NSPredicate(format: "users CONTAINS %@", currentUserID)
        
        cloudKitManager.subscribe(Thread.recordTypeKey, predicate: predicate, subscriptionID: "all messages", contentAvailable: true, options: .FiresOnRecordCreation) { (subscription, error) in
            if error != nil {
                print("Error subscribing to thread: \(error?.localizedDescription)")
                if let completion = completion {
                    completion(success: false, error: error)
                }
            } else {
                if let completion = completion {
                    let success = subscription != nil
                    completion(success: success, error: error)
                }
            }
        }
    }
    
    func subscribeToThreadMessages(thread: Thread, alertBody: String?, completion: ((sucess: Bool, error: NSError?) -> Void)? = nil) {
        
        guard let recordID = thread.threadRecordID else { fatalError("Unable to create CloudKit reference for subscription.") }
        
        let predicate = NSPredicate(format: "thread == %@", recordID)
        
        cloudKitManager.subscribe(Message.recordTypeKey, predicate: predicate, subscriptionID: recordID.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: [Message.textKey, Message.threadKey], options: .FiresOnRecordCreation) { (subscription, error) in
            if error != nil {
                print("Error subscribing to comments in thread \(thread.threadRecordID): \(error?.localizedDescription)")
                if let completion = completion {
                    completion(sucess: false, error: error)
                }
            } else {
                if let completion = completion {
                    let success = subscription != nil
                    completion(sucess: success, error: error)
                }
            }
        }
    }
}















