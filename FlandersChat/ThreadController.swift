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
    
    var threads: [Thread] = [] {
        didSet {
            //
        }
    }
    
    var usersInThreads: [User] = []
    
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
    
    func fetchThreadsForCurrentUser(completion: () -> Void) {
        
        guard let reference = UserController.sharedController.currentUserReference else { completion(); return }
        let predicate = NSPredicate(format: "users CONTAINS %@", reference)
        
        cloudKitManager.fetchRecordsWithType(Thread.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
            //
        }) { (records, error) in
            if error != nil {
                print("Error fetching threads for current user: \(error?.localizedDescription)")
                completion()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    guard let records = records else { completion(); return }
                    for record in records {
                        guard let thread = Thread(record: record) else { completion(); return }
                        self.threads.append(thread)
                    }
                    completion()
                }
            }
        }
    }
}















