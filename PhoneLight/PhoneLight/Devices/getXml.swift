//
//  getXml.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/22/20.
//

import Foundation

public var ipAddress = "10.0.0.251"

class GetXml : NSObject {
    
    struct PortDevices
    {
        var parentPort: String
        var parentName: String
        var devicesOnPort: [DevXml]
    }
    
    private var myData: Data
    var parentList: [String] = []
    var deviceArray: [PortDevices] = []
    var groupLabels: [DevXml] = []
    var groupDict: [String : String] = [:]
    
    override init() {
        myData = "".data(using: .ascii)!
    }
    
    func setData(data: Data!) -> Void
    {
        if data == nil
        {
            return
        }
        
        myData = data
    }
    
    func read() {
        var contents = ""
        let urlField = "https:" + ipAddress + "/ngw/devices.xml"
        let url = URL(string: urlField)!
        let request = URLRequest(url: url)
        
        let sessionDelegate = SessionDelegate()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if data != nil {
                contents = (String(data: data!, encoding: String.Encoding.utf8) as String?)!
                contents = contents.replacingOccurrences(of: "\r", with: "\n")
            }
            
            let p = ParseXml()
            p.setData(data: data)
            p.parse()

            for item in p.items {
                let parentPort = item.parentPort
                if !self.parentList.contains(parentPort) {
                    self.parentList.append(parentPort)
                }
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
                    let devicesPort = PortDevices(parentPort: parent, parentName: "", devicesOnPort: devs)
                    self.deviceArray.append(devicesPort)
                }
            }

            for group in self.groupLabels {
                self.groupDict[group.parentPort] = group.groupLabel     // determine groupLabel dictionary
            }

            if (self.deviceArray.count > 0) {
                for index in 0...(self.deviceArray.count - 1) {             // add in parentName (now that groupLabels dictionary is set)
                    self.deviceArray[index].parentName = self.groupDict[self.deviceArray[index].parentPort] ?? "none"
                }
            }

            self.deviceArray.sort { $0.parentName < $1.parentName}      // sort sections by parentName
            
        }
        task.resume()
    }
}

class SessionDelegate:NSObject, URLSessionDelegate {
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
