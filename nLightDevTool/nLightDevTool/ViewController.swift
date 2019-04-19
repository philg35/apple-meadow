//
//  ViewController.swift
//  nLightDevTool
//
//  Created by Philip Gross on 4/13/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit

/*extension RangeReplaceableCollection where Element: Equatable
{
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element)
    {
        if let index = firstIndex(of: element)
        {
            return (false, self[index])
        }
        else
        {
            append(element)
            return (true, element)
        }
    }
}*/

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    
    @IBOutlet weak var tableview: UITableView!
    
    private var rooms: [DevXml] = []
    
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
            print(contents)
            
            let p = ParseXml()
            p.setData(data: data)
            p.parse()
            
            for item in p.items
            {
                //if self.rooms.contains(where: <#T##(DevXml) throws -> Bool#>)
                //{
                    self.rooms.append(item)
                //}
            }
            DispatchQueue.main.async
            {
                self.tableview.reloadData()
            }
            
        }
        task.resume()
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
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellReuseIdentifier")! as! CustomTableViewCell
        
        let text = rooms[indexPath.row]
        
        
        
        cell.roomLabel.text = text.label
        cell.deviceID.text = text.deviceID
        cell.model.text = text.model
        cell.parentPort.text = text.parent + " : " + text.port
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


