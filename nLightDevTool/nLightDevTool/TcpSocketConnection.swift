//
//  TcpSocketConnection.swift
//  nLightDevTool
//
//  Created by Philip Gross on 8/6/19.
//  Copyright © 2019 Philip Gross. All rights reserved.
//

class TcpSocketConnection: GCDAsyncSocketDelegate {
    
    let tcpSocket: GCDAsyncSocket?
    
    init(host: String, port: UInt16) {
        self.tcpSocket = GCDAsyncSocket(delegate: self)
        do {
            try tcpSocket?.connect(toHost: host, onPort: port, withTimeout: 5.0)
        } catch let error {
            print("Cannot open socket to \(host):\(port): \(error)")
        }
    }
    
    // Needed by TcpSocketServer to start a connection with an accepted socket
    init(socket: GCDAsyncSocket, node: Node) {
        self.tcpSocket = socket
        self.tcpSocket?.delegate = self
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        self.tcpSocket?.readData(toLength: 1024, withTimeout: 60.0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // Process data
        self.tcpSocket?.readData(toLength: 1024, withTimeout: 60.0, tag: 0)
    }
    
    func send(_ data: Data) {
        self.tcpSocket?.write(data, withTimeout: 10, tag: 0)
    }
    
}
