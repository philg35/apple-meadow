//
//  ViewController.swift
//  nLightDevTool
//
//  Created by Philip Gross on 4/13/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var xmlLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func buttonPressed(_ sender: Any)
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
            
            DispatchQueue.main.async
            {
                self.xmlLabel.text = contents
            }
        }
        task.resume()
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
