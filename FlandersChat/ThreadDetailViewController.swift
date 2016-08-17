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
    
    @IBOutlet weak var messageTextField: UITextField!
    
    var thread: Thread?
    var users: [CKReference] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let thread = thread else { return }
        MessagesController.sharedController.fetchMessages(thread) { 
            //
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessagesController.sharedController.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func sendMessagButtonTapped(sender: AnyObject) {
        
        ThreadController.sharedController.createNewThread(users) { 
            self.createMessage()
        }
    }
    
    // MARK: - Helper functions
    
    func createMessage() {
        guard let messageText = messageTextField.text,
            sender = UserController.sharedController.currentUserReference,
            threadRecordID = thread?.cloudKitRecord.recordID else { return }
        
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
