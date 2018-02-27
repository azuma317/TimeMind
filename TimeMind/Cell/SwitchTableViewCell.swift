//
//  SwitchTableViewCell.swift
//  TimeMind
//
//  Created by Azuma on 2018/02/26.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    typealias switchCallback = (Bool) -> Void
    
    var callback: switchCallback?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func switchAction(_ sender: UISwitch) {
        if sender.isOn {
            self.callback?(true)
        } else {
            self.callback?(false)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
