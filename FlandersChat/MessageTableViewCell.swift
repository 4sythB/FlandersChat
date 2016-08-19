//
//  MessageTableViewCell.swift
//  FlandersChat
//
//  Created by Brad on 8/17/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // messageLabel Constraints
    @IBOutlet weak var messageLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabelLeadingConstraint: NSLayoutConstraint!
    
    let cloudKitManager = CloudKitManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateWithMessage(message: Message) {
        
        if message.sender == UserController.sharedController.currentUserReference {
            messageLabelTrailingConstraint.constant = 8
            messageLabelLeadingConstraint.constant = 164
            messageLabel.backgroundColor = UIColor(red: 19/255, green: 187/255, blue: 255/255, alpha: 1.0)
            messageLabel.textColor = UIColor.whiteColor()
            messageLabel.textAlignment = .Right
            senderLabel.textAlignment = .Right
        }
        
        guard let sender = message.senderUser else { return }
        let senderName = "\(sender.firstName) \(sender.lastName)"
        
        senderLabel.text = senderName
        messageLabel.text = message.text
        
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 6.0
    }
}
