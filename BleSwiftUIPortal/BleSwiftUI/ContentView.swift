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
                    }
                    .frame(height: 25)
                }
            }//.padding(-15.0)
 
            Spacer()
 
            HStack {
                    Spacer()
                    Button(action: {
                        self.bleManager.startScanning()
                    }) {
                        Text("Start")
                    }
                    Spacer()
                    Button(action: {
                        self.bleManager.stopScanning()
                    }) {
                        Text("Stop")
                    }
                    Spacer()
                    Button(action: {
                        self.bleManager.clearScan()
                    }) {
                        Text("Clear")
                    }
                    Spacer()
                    VStack() {
                        Text("Portal Only").font(.system(size: 12))
                        Toggle("", isOn: $onlyLocalConnect).labelsHidden()
                            .onChange(of: onlyLocalConnect) { value in
                            self.bleManager.isLocalConnChange(newValue: value)
                        }
                    }
                Spacer()
            }
        }
    }
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
