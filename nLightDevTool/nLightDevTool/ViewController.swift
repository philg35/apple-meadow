//
//  ViewController.swift
//  nLightDevTool
//
//  Created by Philip Gross on 4/13/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit
public var ipAddress = "10.0.0.251"

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate
{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var parentLabel: UILabel!
    @IBOutlet weak var ipAddressField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData: [String] = [String]()
    
    struct PortDevices
    {
        var parentPort: String
        var devicesOnPort: [DevXml]
    }
    
    private var deviceList: [DevXml] = []
    private var parentList: [String] = []
    private var deviceArray: [PortDevices] = []
    private var groupLabels: [DevXml] = []
    private var groupDict: [String : String] = [:]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        
        // Connect data:
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.ipAddressField.delegate = self
        
        // Input the data into the array
        //pickerData = ["10.0.0.251", "10.38.64.249"]
        //read
        let defaults = UserDefaults.standard
        pickerData = defaults.stringArray(forKey: "pickerData") ?? [String]()
    }
    
    @IBAction func removePressed(_ sender: Any) {
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        print("selected", selectedValue)
        pickerData.remove(at: selectedValue)
        self.pickerView.reloadAllComponents()
        savePickerData()
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        print("selected", selectedValue)
        ipAddress = pickerData[selectedValue]
        doXmlRead()
    }
    
    @IBAction func addPressed(_ sender: Any) {
        if ipAddressField.endEditing(false) {
            print("ending editting, button pressed")
            ipAddress = ipAddressField.text ?? "10.0.0.251"
            if !pickerData.contains(ipAddress) {
                print("add it")
                pickerData.append(ipAddress)
                pickerData.sort()
                self.pickerView.reloadAllComponents()
            }
            savePickerData()
        }
        else {
            print("button pressed")
        }
        doXmlRead()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return deviceArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertController = UIAlertController(title: "Hint", message: "You have selected \(indexPath.row)", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return deviceArray[section].devicesOnPort.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return ((self.groupDict[deviceArray[section].parentPort] ?? "nLWired") + " (" + String(deviceArray[section].devicesOnPort.count) + " devices)")
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = UIColor.blue.withAlphaComponent(1)
        
        //(view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.cyan.withAlphaComponent(0.5)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! as! CustomTableViewCell
        
        let text = deviceArray[indexPath.section].devicesOnPort[indexPath.row]
        
        cell.roomLabel.text = text.label
        cell.deviceID.text = text.deviceID
        cell.model.text = text.model
        cell.parentPort.text = text.parentPort
        
        cell.contentView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        return cell
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print(pickerData[row], row, component)
        ipAddress = pickerData[row]
        doXmlRead()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("done editing")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("began editing")
    }
    
    func doXmlRead() {
        var contents = ""
        let urlField = "https:" + ipAddress + "/ngw/devices.xml"
        let url = URL(string: urlField)!
        let request = URLRequest(url: url)
        
        let sessionDelegate = SessionDelegate()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        {
            (data, response, error) in
            
            if data != nil {
                contents = (String(data: data!, encoding: String.Encoding.utf8) as String?)!
                contents = contents.replacingOccurrences(of: "\r", with: "\n")
            }
            
            let p = ParseXml()
            p.setData(data: data)
            p.parse()
            
            p.items.sort {
                $0.model.localizedCaseInsensitiveCompare($1.model) == ComparisonResult.orderedAscending
            }
            self.deviceList.removeAll()
            
            for item in p.items {
                let parentPort = item.parentPort
                if !self.parentList.contains(parentPort) {
                    self.parentList.append(parentPort)
                }
            }
            self.parentList.sort {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
            
            self.deviceArray.removeAll()    // clear all to start
            for parent in self.parentList {
                var devs: [DevXml] = []
                for device in p.items {
                    if device.parentPort == parent {
                        if device.groupLabel != "" {
                            self.groupLabels.append(device)
                        }
                        else if !device.model.contains("POD") && !device.model.contains("ECYD") {
                            devs.append(device)
                        }
                    }
                }
                if devs.count > 0 {
                    devs.sort {
                        $0.model.localizedCaseInsensitiveCompare($1.model) == ComparisonResult.orderedAscending
                    }
                    let devicesPort = PortDevices(parentPort: parent, devicesOnPort: devs)
                    self.deviceArray.append(devicesPort)
                }
            }
            for group in self.groupLabels {
                self.groupDict[group.parentPort] = group.groupLabel
            }
            print(self.deviceArray)
            
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
        task.resume()
    }
    
    func savePickerData() {
        //save
        let defaults = UserDefaults.standard
        defaults.set(pickerData, forKey: "pickerData")
    }
}

class SessionDelegate:NSObject, URLSessionDelegate
{
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust)
        {
            print("in session delegate")
            print(challenge.protectionSpace.host)
            if(challenge.protectionSpace.host == ipAddress)
            {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
}


