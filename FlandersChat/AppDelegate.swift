//
//  AppDelegate.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let cloudKitManager = CloudKitManager()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        cloudKitManager.requestDiscoverabilityPermission()
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        guard let userInfo = userInfo as? [String : NSObject] else { return }
        let queryNotification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
        
        guard let recordID = queryNotification.recordID else { return }
        
        cloudKitManager.fetchRecordWithID(recordID) { (record, error) in
            guard let record = record,
            message = Message(record: record) else { return }
            let threadRecordID = message.thread.recordID
            
            MessagesController.sharedController.fetchSenderForMessage(message, completion: { 
                self.cloudKitManager.fetchRecordWithID(threadRecordID, completion: { (record, error) in
                    guard let threadRecord = record,
                        thread = ThreadController.sharedController.threads.filter({$0.threadRecordID == threadRecord.recordID}).first else { return }
                    thread.messages.append(message)
                })
            })
        }
        completionHandler(UIBackgroundFetchResult.NewData)
    }
}











