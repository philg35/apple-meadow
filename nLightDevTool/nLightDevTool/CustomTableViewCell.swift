//
//  CustomTableViewCell.swift
//  nLightDevTool
//
//  Created by Philip Gross on 4/18/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit

protocol PressSwitchDelegate {
    func didPressSwitch(deviceID: String, newState: Bool)
}

class CustomTableViewCell: UITableViewCell
{
    @IBOutlet weak var deviceID: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var model: UILabel!
    @IBOutlet weak var parentPort: UILabel!
    
    var delegate: PressSwitchDelegate?
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        delegate?.didPressSwitch(deviceID: deviceID.text!, newState: sender.isOn)
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
