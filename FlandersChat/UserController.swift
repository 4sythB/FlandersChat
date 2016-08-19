//
//  UserController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    let cloudKitManager = CloudKitManager()
    static let sharedController = UserController()
    
    var currentUserRecordID: CKRecordID?
    var currentUserReference: CKReference?
    
    var users: [User] = []
    
    func createNewUser(completion: () -> Void) {
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            guard let record = record else { completion(); return }
            self.currentUserRecordID = record.recordID
            guard let userRecordID = self.currentUserRecordID else { completion(); return }
            
            self.currentUserReference = CKReference(recordID: userRecordID, action: .None)
            
            self.cloudKitManager.fetchUsernameFromRecordID(userRecordID, completion: { (givenName, familyName) in
                guard let firstName = givenName,
                    lastName = familyName,
                    reference = self.currentUserReference else {
                        completion()
                        return
                }
                
                let userRecord = CKRecord(recordType: User.recordTypeKey)
                userRecord.setValue(firstName, forKey: User.firstNameKey)
                userRecord.setValue(lastName, forKey: User.lastNameKey)
                userRecord.setValue(reference, forKey: User.referenceKey)
                
                self.cloudKitManager.saveRecord(userRecord, completion: { (_, error) in
                    if error != nil {
                        print("Error saving current user record to cloudKit: \(error?.localizedDescription)")
                        completion()
                    }
                    print("Successfully saved new user to cloudKit.")
                    completion()
                })
            })
        }
    }
    
    func fetchCurrentUserRecord(completion: (success: Bool) -> Void) {
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            guard let record = record else { completion(success: false); return }
            self.currentUserRecordID = record.recordID
            
            let recordID = record.recordID
            
            let predicate = NSPredicate(format: "reference == %@", recordID)
            
            self.cloudKitManager.fetchRecordsWithType(User.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
                self.currentUserRecordID = record.recordID
                guard let currentUserID = self.currentUserRecordID else { return }
                let user = User(record: record)
                user?.record = record
                self.currentUserReference = CKReference(recordID: currentUserID, action: .None)
            }) { (records, error) in
                if error != nil {
                    print("Error fetching current user record: \(error?.localizedDescription)")
                    completion(success: false)
                } else if records?.count == 0 {
                    completion(success: false)
                } else if records?.count > 0 {
                    completion(success: true)
                }
            }
        }
    }
    
    func fetchAllUsers(completion: () -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        cloudKitManager.fetchRecordsWithType(User.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
            //
        }) { (records, error) in
            if error != nil {
                print("Error fetching users for contact list: \(error?.localizedDescription)")
            } else {
                guard let records = records else { completion(); return }
                for record in records {
                    guard let user = User(record: record) else { completion(); return }
                    self.users.append(user)
                    completion()
                }
            }
        }
    }
}















