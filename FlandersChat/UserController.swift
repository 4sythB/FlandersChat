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
    
    var currentUserRecordID: CKRecordID?
    var currentUserReference: CKReference?
    
    var users: [User] = []
    
    func createNewUser(completion: () -> Void) {
        
        cloudKitManager.fetchLoggedInUserRecord { (record, error) in
            self.currentUserRecordID = record?.recordID
            guard let userRecordID = self.currentUserRecordID else { completion(); return }
            
            self.currentUserReference = CKReference(recordID: userRecordID, action: .None)
            
            self.cloudKitManager.fetchUsernameFromRecordID(userRecordID, completion: { (givenName, familyName) in
                guard let firstName = givenName,
                    lastName = familyName,
                    reference = self.currentUserReference else { completion(); return }
                
                let userRecord = CKRecord(recordType: User.recordTypeKey, recordID: userRecordID)
                userRecord.setValue(firstName, forKey: User.firstNameKey)
                userRecord.setValue(lastName, forKey: User.lastNameKey)
                userRecord.setValue(reference, forKey: User.referenceKey)
                
                self.cloudKitManager.saveRecord(userRecord, completion: { (_, error) in
                    if error != nil {
                        print("Error saving current user record to cloudKit: \(error?.localizedDescription)")
                        completion()
                    }
                    completion()
                })
            })
        }
    }
    
    func fetchCurrentUserRecord(completion: () -> Void) {
        guard let userReference = currentUserReference else { completion(); return }
        
        let predicate = NSPredicate(format: "reference == %@", userReference)
        
        cloudKitManager.fetchRecordsWithType(User.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
            self.currentUserRecordID = record.recordID
        }) { (records, error) in
            if error != nil {
                print("Error fetching current user record: \(error?.localizedDescription)")
                completion()
            }
            completion()
        }
    }
    
    func fetchAllUsers(completion: () -> Void) {
        
        let predicate = NSPredicate(value: true)
        
        cloudKitManager.fetchRecordsWithType(User.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
            
            guard let user = User(record: record) else { completion(); return }
            self.users.append(user)
            
        }) { (records, error) in
            if error != nil {
                print("Error fetching users for contact list: \(error?.localizedDescription)")
            }
        }
    }
}















