//
//  ViewController.swift
//  nLightDevTool
//
//  Created by Philip Gross on 4/13/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var parentLabel: UILabel!
    
    struct PortDevices
    {
        var parentPort: String
        var devicesOnPort: [DevXml]
    }
    
    private var deviceList: [DevXml] = []
    private var parentList: [String] = []
    private var deviceArray: [PortDevices] = []
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
    }
    
    @IBAction func refreshPressed(_ sender: Any)
    {
        print("button pressed")
        var contents = ""
        let url = URL(string: "https://10.0.0.251/ngw/devices.xml")!
        let request = URLRequest(url: url)
        
        let sessionDelegate = SessionDelegate()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: request)
        {
            (data, response, error) in
            
            contents = (String(data: data!, encoding: String.Encoding.utf8) as String?)!
            contents = contents.replacingOccurrences(of: "\r", with: "\n")
            //print(contents)
            
            let p = ParseXml()
            p.setData(data: data)
            p.parse()
            
            p.items.sort {
                $0.model.localizedCaseInsensitiveCompare($1.model) == ComparisonResult.orderedAscending
            }
            self.deviceList.removeAll()
            
            for item in p.items
            {
                //self.deviceList.append(item)
                let parentPort = item.parentPort
                if !self.parentList.contains(parentPort)
                {
                    self.parentList.append(parentPort)
                }
            }
            self.parentList.sort {
                $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending
            }
            
            for parent in self.parentList
            {
                var devs: [DevXml] = []
                for device in p.items
                {
                    if device.parentPort == parent
                    {
                        if device.model != "" && !device.model.contains("POD") && !device.model.contains("ECYD")
                        {
                            devs.append(device)
                        }
                    }
                }
                if devs.count > 0
                {
                    devs.sort {
                        $0.model.localizedCaseInsensitiveCompare($1.model) == ComparisonResult.orderedAscending
                    }
                    let devicesPort = PortDevices(parentPort: parent, devicesOnPort: devs)
                    self.deviceArray.append(devicesPort)
                }
            }
            
            print(self.deviceArray)
            //print(self.deviceList.count)
            //print(self.parentList)
            
            DispatchQueue.main.async
            {
                
                self.tableview.reloadData()
            }
            
        }
        task.resume()
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
        return deviceArray[section].parentPort
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! as! CustomTableViewCell
        
        let text = deviceArray[indexPath.section].devicesOnPort[indexPath.row]
        
        
        
        cell.roomLabel.text = text.label
        cell.deviceID.text = text.deviceID
        cell.model.text = text.model
        cell.parentPort.text = text.parentPort
        if cell.model.text?.contains("POD") ?? false
        {
            cell.contentView.backgroundColor = UIColor.yellow
        }
        else if cell.model.text?.prefix(1) == "r"
        {
            cell.contentView.backgroundColor = UIColor.orange
        }
        else if cell.model.text?.prefix(1) == "n"
        {
            cell.contentView.backgroundColor = UIColor.green
        }
        else
        {
            cell.contentView.backgroundColor = UIColor.lightGray
        }
        return cell
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
            if(challenge.protectionSpace.host == "10.0.0.251")
            {
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
            }
        }
    }
}


