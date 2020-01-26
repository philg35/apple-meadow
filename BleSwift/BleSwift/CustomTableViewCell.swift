//
//  File.swift
//  BleSwift
//
//  Created by Philip Gross on 1/19/20.
//  Copyright © 2020 Philip Gross. All rights reserved.
//

import UIKit


class CustomTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var macLabel: UILabel!
    @IBOutlet weak var updateLabel: UILabel!
    @IBOutlet weak var mfgdataLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}

