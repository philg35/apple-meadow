//
//  getMqttPubs.swift
//  Light
//
//  Created by Philip Gross on 1/8/21.
//

import Foundation

//public var ipAddress = "10.0.0.251"

class GetMqttPubs : NSObject {
    
    struct MqttInfo
    {
        var deviceId: String
        var mqttPubs: [String]
    }
    
    private var myData: Data
    var readIsReady: Bool = false
    var pubsInfo = [MqttInfo]()
        
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
    
    func startRead() {
        self.readIsReady = false;
        
    }
    
    func readReady() -> Bool {
        return self.readIsReady
    }
    
    func read(phoneLightData: [PhoneLight]) {
        var contents = ""
        let urlField = "https:" + ipAddress + "/ngw/mqtt_pubs.txt"
        let url = URL(string: urlField)!
        let request = URLRequest(url: url)
        
        let sessionDelegate = SessionDelegate2()
        let session = URLSession(configuration: .default, delegate: sessionDelegate, delegateQueue: nil)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            if data != nil {
                contents = (String(data: data!, encoding: String.Encoding.utf8) as String?)!
                //contents = contents.replacingOccurrences(of: "\r", with: "\n")
            }
            
            print("*** printing contents")
            let lines = contents.split(whereSeparator: \.isNewline)
            
    
            for d in phoneLightData {
                let entry: MqttInfo = MqttInfo(deviceId: d.deviceId, mqttPubs: [])
                self.pubsInfo.append(entry)
            }
            //print(self.pubsInfo)
            
            for line in lines {
                for (index, element) in self.pubsInfo.enumerated() {
                    if line.contains(element.deviceId) {
                        let components = line.components(separatedBy: "{")
                        if (!components[1].contains("measured-light-level") && !components[1].contains("dimming-output-level") && !components[1].contains("occupied")) {
                            self.pubsInfo[index].mqttPubs.append(String(components[1]))
                        }
                    }
                }
            }
            self.readIsReady = true
        }
        task.resume()
    }
}

class SessionDelegate2:NSObject, URLSessionDelegate {
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

