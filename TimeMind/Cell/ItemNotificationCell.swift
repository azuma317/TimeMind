//
//  ItemNotificationCell.swift
//  TimeMind
//
//  Created by Azuma on 2018/02/28.
//  Copyright © 2018年 Azuma. All rights reserved.
//

import UIKit

class ItemNotificationCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
