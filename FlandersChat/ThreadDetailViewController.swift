//
//  ThreadDetailViewController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import CloudKit

class ThreadDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var thread: Thread?
    var users: [CKReference] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let thread = thread else { return }
        MessagesController.sharedController.fetchMessages(thread) {
            // Fetch users for each message/assign the user to that message
            let messages = thread.messages
            for message in messages {
                MessagesController.sharedController.fetchSenderForMessage(message, completion: {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let thread = thread  else { return 0 }
        return thread.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as? MessageTableViewCell,
            thread = thread  else { return UITableViewCell() }
        let message = thread.messages[indexPath.row]
        
        cell.updateWithMessage(message)
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func sendMessagButtonTapped(sender: AnyObject) {
        
        createMessage()
    }
    
    // MARK: - Helper functions
    
    func createMessage() {
        guard let messageText = messageTextField.text,
            currentUserRecordID = UserController.sharedController.currentUserReference?.recordID,
            thread = thread,
            threadRecordID = thread.threadRecordID else { print("Unable to create message"); return }
        
        let sender = CKReference(recordID: currentUserRecordID, action: .None)
        let threadReference = CKReference(recordID: threadRecordID, action: .DeleteSelf)
        
        let message = Message(text: messageText, sender: sender, thread: threadReference)
        
        MessagesController.sharedController.saveMessage(message) {
            dispatch_async(dispatch_get_main_queue()) {
                self.messageTextField.text = ""
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
