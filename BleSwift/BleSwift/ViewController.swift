//
//  ViewController.swift
//  BleSwift
//
//  Created by Philip Gross on 1/19/20.
//  Copyright © 2020 Philip Gross. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController, CBCentralManagerDelegate {
    private var centralManager : CBCentralManager!
    @IBOutlet weak var tableView: UITableView!
    
    
    struct bleDevice
    {
        var bleName: String = ""
        var bleIdentifier: String = ""
        var bleRssi: String = ""
    }
    private var deviceArray : [bleDevice] = []
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is On")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
        else {
            print("Bluetooth is not active")
        }
    }
    

    override func viewDidLoad() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
    }


    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if Int(RSSI) > -70 {
            
            print("\nName   : \(peripheral.name ?? "(No name)")")
            print("RSSI   : \(RSSI)")
            for ad in advertisementData {
                print("AD Data: \(ad)")
            }
        
        
            var dev : bleDevice
            dev = bleDevice(bleName: peripheral.name ?? "(No name)", bleIdentifier: peripheral.identifier.uuidString, bleRssi: RSSI.stringValue)
            
            var found = false
            for (index, device) in deviceArray.enumerated() {
                if device.bleIdentifier == peripheral.identifier.uuidString {
                    deviceArray[index] = device
                    found = true
                    print("updating...", index)
                }
            }
            
            if found == false {
                deviceArray.append(dev)
            }
            
            deviceArray.sort {
                $0.bleRssi.localizedCaseInsensitiveCompare($1.bleRssi) == ComparisonResult.orderedAscending
            }
            
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "BLE devices"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.red
        header.contentView.backgroundColor = UIColor.white
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! as! CustomTableViewCell
        
        let text = deviceArray[indexPath.row]
        
        cell.nameLabel.text = text.bleName
        cell.macLabel.text = text.bleIdentifier
        cell.rssiLabel.text = text.bleRssi
        
        cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        
        return cell
    }
}
