//
//  ThreadDetailViewController.swift
//  FlandersChat
//
//  Created by Brad on 8/15/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit

class ThreadDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var thread: Thread?

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
