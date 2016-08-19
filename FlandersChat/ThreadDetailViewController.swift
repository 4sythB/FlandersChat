//
//  ThreadDetailViewController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import CloudKit

class ThreadDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var toolbarView: UIView!
    @IBOutlet weak var toolbarViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var toolbarBottomConstraintInitialValue: CGFloat = 0
    
    var thread: Thread?
    var users: [CKReference] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorStyle = .None
        
        messageTextField.delegate = self
        
        enableKeyboardHideOnTap()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(messagesWereUpdated), name: "messageAdded", object: nil)
        
        guard let thread = thread else { return }

        thread.messages = []
        MessagesController.sharedController.fetchMessages(thread) {
            // Fetch users for each message/assign the user to that message
            let messages = thread.sortedMessages
            for message in messages {
                MessagesController.sharedController.fetchSenderForMessage(message, completion: {
                    dispatch_async(dispatch_get_main_queue()) {
                        let indexPath = NSIndexPath(forRow: thread.messages.count - 1, inSection: 0)
                        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: false)
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func messagesWereUpdated() {
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let thread = thread  else { return 0 }
        return thread.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("messageCell", forIndexPath: indexPath) as? MessageTableViewCell,
            thread = thread  else { return UITableViewCell() }
        let message = thread.sortedMessages[indexPath.row]
        
        cell.updateWithMessage(message)
        
        return cell
    }
    
    // MARK: - Actions
    
    @IBAction func sendMessagButtonTapped(sender: AnyObject) {
        if messageTextField.text?.characters.count > 0 {
            createMessage({
                guard let thread = self.thread else { return }
                self.tableView.reloadData()
                let indexPath = NSIndexPath(forRow: thread.messages.count - 1, inSection: 0)
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
            })
        }
    }
    
    // MARK: - Helper functions
    
    func createMessage(completion: (() -> Void)? = nil ) {
        guard let messageText = messageTextField.text,
            currentUserRecordID = UserController.sharedController.currentUserReference?.recordID,
            thread = thread,
            threadRecordID = thread.threadRecordID else { print("Unable to create message"); return }
        
        let sender = CKReference(recordID: currentUserRecordID, action: .None)
        let threadReference = CKReference(recordID: threadRecordID, action: .DeleteSelf)
        
        let message = Message(text: messageText, sender: sender, thread: threadReference)
        
        MessagesController.sharedController.fetchSenderForMessage(message) { 
            MessagesController.sharedController.saveMessage(message) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.messageTextField.text = ""
                    thread.messages.append(message)
                    completion?()
                }
            }
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
            UIView.animateWithDuration(duration, animations: { 
                if self.toolbarViewBottomConstraint.constant == 0 {
                    self.toolbarViewBottomConstraint.constant += keyboardSize.height
                    self.tableViewBottomConstraint.constant += keyboardSize.height
                }
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }
            UIView.animateWithDuration(duration, animations: {
                if self.toolbarViewBottomConstraint.constant != 0 {
                    self.toolbarViewBottomConstraint.constant -= keyboardSize.height
                    self.tableViewBottomConstraint.constant -= keyboardSize.height
                }
            })
        }
    }
    
    private func enableKeyboardHideOnTap(){
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
}










