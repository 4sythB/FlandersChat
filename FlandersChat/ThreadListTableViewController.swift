//
//  ThreadListTableViewController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import CloudKit

class ThreadListTableViewController: UITableViewController {
    
    let cloudKitManager = CloudKitManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cloudKitManager.checkCloudKitAvailability()
        
        UserController.sharedController.fetchCurrentUserRecord { (success) in
            if !success {
                UserController.sharedController.createNewUser({
                    //
                })
            } else {
                ThreadController.sharedController.fetchThreadsForCurrentUser({
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ThreadController.sharedController.threads.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("threadCell", forIndexPath: indexPath)
        let thread = ThreadController.sharedController.threads[indexPath.row]
        
        updateLabel(thread) { (name) in
            dispatch_async(dispatch_get_main_queue()) {
                guard let name = name else { return }
                cell.textLabel?.text = name
            }
        }
        return cell
    }
    
    func updateLabel(thread: Thread, completion: (name: String?) -> Void) {
        
        for user in thread.users {
            let predicate = NSPredicate(format: "reference == %@", user.recordID)
            cloudKitManager.fetchRecordsWithType(User.recordTypeKey, predicate: predicate, recordFetchedBlock: { (record) in
                guard let user = User(record: record) else { completion(name: nil); return }
                UserController.sharedController.users.append(user)
                completion(name: "\(user.firstName) \(user.lastName)")
                }, completion: { (records, error) in
                    completion(name: nil)
            })
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toThreadDetailSegue" {
            guard let destinationVC = segue.destinationViewController as? ThreadDetailViewController,
                indexPath = tableView.indexPathForSelectedRow else { return }
            
            let thread = ThreadController.sharedController.threads[indexPath.row]
            
            destinationVC.thread = thread
        }
    }
}












