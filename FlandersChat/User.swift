//
//  User.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CloudKit

class User {
    
    static let recordTypeKey = "user"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let referenceKey = "reference"
    
    let firstName: String
    let lastName: String
    let reference: CKReference
    
    var record: CKRecord?
    
    init(firstName: String, lastName: String, reference: CKReference) {
        self.firstName = firstName
        self.lastName = lastName
        self.reference = reference
    }
    
    convenience init?(record: CKRecord) {
        guard let firstName = record[User.firstNameKey] as? String,
            lastName = record[User.lastNameKey] as? String,
            reference = record[User.referenceKey] as? CKReference else { return nil }
        
        self.init(firstName: firstName, lastName: lastName, reference: reference)
    }
}