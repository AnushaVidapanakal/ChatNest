import Foundation
import UIKit
import QuartzCore

class VCCells: UITableViewCell{
    
}
class SenderCell: UITableViewCell {
    
    @IBOutlet weak var senderMsgLabel: UILabel!
    @IBOutlet private weak var senderNameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet weak var senderView: UIView!
    
    func clearCellData()  {
        self.senderMsgLabel.text = nil
        //self.senderMsgLabel.isHidden = false
    }
    
    func updateMessage(message: Message) {
        
        self.senderMsgLabel.text = message.text
        senderNameLabel.text = message.senderName
        timeLabel.text = message.dateString
        senderView.layer.cornerRadius = 8
    }
    
}

class ReceiverCell: UITableViewCell {
    
    @IBOutlet weak var receiverMsgLabel: UILabel!
    @IBOutlet weak var receiverNameLabel: UILabel!
    @IBOutlet weak var rtimeLabel: UILabel!
    @IBOutlet weak var receiverView: UIView!
    
    func clearCellData()  {
        self.receiverMsgLabel.text = nil
    }
    
    func updateMessage(message: Message) {
        // rMessageView.layer.cornerRadius = 10.0
        
        self.receiverMsgLabel.text = message.text
        receiverNameLabel.text = message.senderName
        rtimeLabel.text = message.dateString
        receiverView.layer.cornerRadius = 8
    }
    
}

