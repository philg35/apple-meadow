//
//  ContentView.swift
//  BleSwiftUI
//
//  Created by Philip Gross on 1/19/20.
//  Copyright © 2020 Philip Gross. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var bleManager = BLEManager()
    @StateObject var perifManager = BLEPerifManager()
    @State var onlyLocalConnect : Bool = true
    
    var body: some View {
        VStack (spacing: 10) {
 
            Text("Bluetooth Devices")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
            
            NavigationView {
                List(bleManager.peripherals) { peripheral in
                    NavigationLink(destination: PeriphDetail(periph: peripheral, bleManager: bleManager)) {
                        PeriphRow(periph: peripheral)
                    }//.background(Color("RowBackground"))
                    .frame(height: 25)
                }
            }.padding(-15.0)
 
            Spacer()
            
            HStack {
                VStack {
                    Text("STATUS")
                        .font(.headline)
         
                    // Status goes here
                    if bleManager.isSwitchedOn {
                        Text("Bluetooth is switched on")
                            .foregroundColor(.green)
                    }
                    else {
                        Text("Bluetooth is NOT switched on")
                            .foregroundColor(.red)
                    }
                }
                if #available(iOS 14.0, *) {
                    Toggle(isOn: $onlyLocalConnect) {
                        Text("Portal Only")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }.onChange(of: onlyLocalConnect) { value in
                        self.bleManager.isLocalConnChange(newValue: value)
                    }.padding()
                } else {
                    // Fallback on earlier versions
                }
                
            }
            
            Spacer()
 
            HStack {
                //VStack (spacing: 10) {
                    Spacer()
                    Button(action: {
                        self.bleManager.startScanning()
                    }) {
                        Text("Start Scan")
                    }
                    Spacer()
                    Button(action: {
                        self.bleManager.stopScanning()
                    }) {
                        Text("Stop Scan")
                    }
                    Spacer()
                    Button(action: {
                        self.bleManager.clearScan()
                    }) {
                        Text("Clear Scan")
                    }
                    Spacer()
            }
            Spacer()
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
