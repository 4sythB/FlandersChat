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
        
        guard let sender = message.senderUser else { return }
        let senderName = "\(sender.firstName) \(sender.lastName)"
        
        senderLabel.text = senderName
        messageLabel.text = message.text
    }
}
