//
//  PeriphDetail.swift
//  BleSwiftUI
//
//  Created by Philip Gross on 9/11/21.
//  Copyright © 2021 Philip Gross. All rights reserved.
//

import SwiftUI

final class Params: ObservableObject {
  static let global = Params()

    var lcOfInterest = ""
    var portalName = ""
    var lcData = ""
}

struct PeriphDetail: View {
    
    var periph : Peripheral
    @ObservedObject var bleManager: BLEManager
    @ObservedObject public var global = Params.global
    
    var body: some View {
        Text("\(periph.name), \(periph.rssi)").font(.headline)
        
        HStack {
            Spacer()
            Button(action: {self.bleManager.connect(periphConn: periph)}, label: {
                Text("Connect")
            })
            Spacer()
            Button(action: {self.bleManager.disconnect(periphConn: periph)}, label: {
                Text("Disconnect")
            })
            Spacer()
        }
        HStack {
            VStack {
                Text("Services:")
                ScrollView {
                    Text("\(periph.serviceList)")
                        .multilineTextAlignment(.leading)
                    //.padding(.leading, 10)
                }.frame(height: 70)
            }
            
            VStack {
                Text("Characteristics:")
                ScrollView {
                    Text("\(periph.characteristicList)")
                        .multilineTextAlignment(.leading)
                    //.padding(.leading, 10)
                }.frame(height: 70)
            }
        }
        HStack {
            Button(action: {self.bleManager.readCharacteristicFromString(charString: "B0730002-6604-4CA1-A5A4-98864F059E4A")}, label: { Text("Read")})
            
            
            TextField("PortalName", text: $global.portalName)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
            
            Button(action: {self.bleManager.writeCharacteristicFromString(charString: "B0730002-6604-4CA1-A5A4-98864F059E4A", textString: global.portalName)}, label: { Text("Write")})
        }
        
        HStack {
            Button(action: {self.bleManager.readCharacteristicFromString(charString: "674F0002-8B40-11EC-A8A3-0242AC120002")}, label: { Text("Read")})
            
            
            TextField("LCofInterest", text: $global.lcOfInterest)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
            
            Button(action: {self.bleManager.writeCharacteristicFromInt32(charString: "674F0002-8B40-11EC-A8A3-0242AC120002", payload: UInt32(global.lcOfInterest, radix: 16) ?? 0)}, label: { Text("Write")})
        }
        
        Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "674F0006-8B40-11EC-A8A3-0242AC120002", payload: 1)}, label: { Text("Toggle")})
        
        
        HStack {
            Button(action: {self.bleManager.readCharacteristicFromString(charString: "674F0003-8B40-11EC-A8A3-0242AC120002")}, label: { Text("Read")})
            
            
            TextField("LcData", text: $global.lcData)
                .multilineTextAlignment(.center)
                .textFieldStyle(.roundedBorder)
                .frame(width: 150)
            
            Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "674F0003-8B40-11EC-A8A3-0242AC120002", payload: UInt8(global.lcData, radix: 16) ?? 0)}, label: { Text("Write")})
        }
        
        VStack {
            ScrollViewReader { proxy in
                   ScrollView {
                       Text("\(periph.readOutput)")
                           .id(1)            // this is where to add an id
                           .multilineTextAlignment(.leading)
                           .font(.system(size: 14, weight: .light, design: .default))
                           .padding()
                   }
                   .onChange(of: periph.readOutput) { _ in
                        proxy.scrollTo(1, anchor: .bottom)
                   }
                }
        }
        Spacer()
    }
}

//struct PeriphDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeriphDetail(periph: {})
//    }
//}
