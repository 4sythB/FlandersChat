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
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewTrailingConstraint: NSLayoutConstraint!

    let cloudKitManager = CloudKitManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bubbleView.layer.cornerRadius = 10.0
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: bubbleView, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: messageLabel, attribute: .Width, multiplier: 1, constant: 1))
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func updateWithMessage(message: Message) {
        
        if message.sender == UserController.sharedController.currentUserReference {
            
            stackView.alignment = .Trailing
            stackViewTrailingConstraint.constant = 0
            stackViewLeadingConstraint.constant = 125
            bubbleView.backgroundColor = UIColor(red: 19/255, green: 187/255, blue: 255/255, alpha: 1.0)
            messageLabel.textColor = UIColor.whiteColor()
            messageLabel.textAlignment = .Left
            senderLabel.textAlignment = .Left
            
        } else if message.sender != UserController.sharedController.currentUserReference {

            stackView.alignment = .Leading
            stackViewLeadingConstraint.constant = 0
            stackViewTrailingConstraint.constant = 125
            bubbleView.backgroundColor = UIColor.lightGrayColor()
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.textAlignment = .Left
            senderLabel.textAlignment = .Left
        }
        
        guard let sender = message.senderUser else { return }
        let senderName = "\(sender.firstName) \(sender.lastName)"
        
        senderLabel.text = senderName
        messageLabel.text = message.text
    }
}




