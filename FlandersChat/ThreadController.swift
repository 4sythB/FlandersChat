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
    
    let cloudKitManager = CloudKitManager()
    
    var threads: [Thread] = []
    
    func createNewThread(users: [CKReference], completion: () -> Void) {
        
        let thread = Thread(users: users)
        let threadRecord = thread.cloudKitRecord
        
        threads.append(thread)
        
        cloudKitManager.saveRecord(threadRecord) { (_, error) in
            if error != nil {
                print("Error saving new thread to cloudKit: \(error?.localizedDescription)")
            }
        }
    }
}