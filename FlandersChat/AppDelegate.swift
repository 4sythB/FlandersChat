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
        
        guard let userInfo = userInfo as? [String : NSObject],
            threadRecordIDString = userInfo["ck"]?.valueForKey("qry")?.valueForKey("af")?.valueForKey("thread") as? String else { return }
        let threadRecordID = CKRecordID(recordName: threadRecordIDString)
        
        for thread in ThreadController.sharedController.sortedThreads {
            if thread.threadRecordID != threadRecordID {
                cloudKitManager.fetchRecordWithID(threadRecordID, completion: { (record, error) in
                    guard let record = record else {
                        print("Unable to fetch recordID from CKRecord")
                        return
                    }
                    switch record.recordType {
                    case Thread.recordTypeKey:
                        guard let _ = Thread(record: record) else { return }
                        return
                    case Message.recordTypeKey:
                        guard let _ = Message(record: record) else { return }
                        return
                    default:
                        return
                    }
                })
            } else {
                cloudKitManager.fetchRecordWithID(threadRecordID, completion: { (record, error) in
                    guard let record = record else { return }
                    if record.recordType == Message.recordTypeKey {
                        guard let message = Message(record: record) else { return }
                        thread.messages.append(message)
                        return
                    }
                })
            }
        }
        completionHandler(UIBackgroundFetchResult.NewData)
    }
}











