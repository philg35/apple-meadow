//
//  ViewController.swift
//  BleSwift
//
//  Created by Philip Gross on 1/19/20.
//  Copyright © 2020 Philip Gross. All rights reserved.
//

import UIKit
import CoreBluetooth



class ViewController: UIViewController, CBCentralManagerDelegate, UITextFieldDelegate {
    private var centralManager : CBCentralManager!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBAction func stopTapped(_ sender: Any) {
        centralManager.stopScan()
    }
    
    @IBAction func scanTapped(_ sender: Any) {
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : NSNumber(value: true)])
        rssiLimit.endEditing(true)
    }
    
    @IBAction func clearTapped(_ sender: Any) {
        deviceArray.removeAll()
        self.tableView.reloadData()
    }
    
    struct bleDevice
    {
        var bleName: String = ""
        var bleIdentifier: String = ""
        var bleRssi: String = ""
        var updateNum: Int = 0
        var mfgData: String = ""
    }
    private var deviceArray : [bleDevice] = []
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is On")
            
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
        rssiLimit.delegate = self
    }

    @IBOutlet weak var rssiLimit: UITextField!
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let rssiNum = Int(rssiLimit.text ?? "-70") ?? -70
        if Int(truncating: RSSI) > rssiNum {
            
            var mfgDataValue = ""
            print("\nName   : \(peripheral.name ?? "(No name)")")
            print("RSSI   : \(RSSI)")
            for ad in advertisementData {
                if ad.key == "kCBAdvDataManufacturerData"
                {
                    //let str = String(decoding: ad.value, as: UTF8.self)
                    
                    if let data = ad.value  as? Data {
                        let dataStr = String(data: data, encoding: .utf8)
                        mfgDataValue = dataStr ?? "strange nLAir data type"
                    }
                    
                    print(ad.value)
                    print(mfgDataValue)
                    
                }
                
                    print(ad)
                
            }
        
            var dev : bleDevice
            dev = bleDevice(bleName: peripheral.name ?? "(No name)", bleIdentifier: peripheral.identifier.uuidString, bleRssi: RSSI.stringValue, mfgData: mfgDataValue)
            
            var found = false
            for (index, device) in deviceArray.enumerated() {
                if device.bleIdentifier == peripheral.identifier.uuidString {
                    dev.updateNum = device.updateNum + 1
                    deviceArray[index] = dev
                    found = true
                }
            }
            
            if found == false {
                deviceArray.append(dev)
            }
            
            deviceArray.sort {
                $0.bleRssi.localizedCaseInsensitiveCompare($1.bleRssi) == ComparisonResult.orderedAscending
            }
            countLabel.text = String(deviceArray.count)
            self.tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        print("connected")
    }
    
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        print("update")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connect")
    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("restore")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("fail")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnect")
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
        cell.updateLabel.text = String(text.updateNum)
        cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        cell.mfgdataLabel.text = text.mfgData
        return cell
    }
}
