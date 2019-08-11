//
//  CustomTableViewCell.swift
//  tableviewSwift
//
//  Created by Philip Gross on 3/20/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var RoomLabel: UILabel!
    @IBOutlet weak var RoomSlider: UISlider!
    @IBOutlet weak var RoomSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        RoomSwitch.actions(forTarget: <#T##Any?#>, forControlEvent: <#T##UIControl.Event#>)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
