//
//  ContactsTableViewController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import CloudKit

class ContactsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserController.sharedController.users = []

        UserController.sharedController.fetchAllUsers {
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UserController.sharedController.users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)

        let user = UserController.sharedController.users[indexPath.row]
        cell.textLabel?.text = "\(user.firstName) \(user.lastName)"

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "contactsToComposeSegue" {
            guard let destinationVC = segue.destinationViewController as? ThreadDetailViewController,
                indexPaths = tableView.indexPathsForSelectedRows else { return }
            
            var users: [User] = []
            var usersReferences: [CKReference] = []
            
            for indexPath in indexPaths {
                let user = UserController.sharedController.users[indexPath.row]
                users.append(user)
            }
            
            for user in users {
                guard let userRecord = user.record else {
                    return
                }
                let userReference = CKReference(recordID: userRecord.recordID, action: .None)
                usersReferences.append(userReference)
            }
            
            ThreadController.sharedController.createNewThread(usersReferences, completion: { (thread) in
                ThreadController.sharedController.subscribeToThreadMessages(thread, alertBody: "You have a new message")
                destinationVC.thread = thread
                destinationVC.users = usersReferences
            })
        }
    }
}












