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
    var lcList: [String] = ["pick"]
    var zoneOfInterest = ""
    var lastPressed = ""
    var lastType = ""
    var kvpData = ""
}

struct PeriphDetail: View {
    
    var periph : Peripheral
    @ObservedObject var bleManager: BLEManager
    @ObservedObject public var global = Params.global
    @State private var selection = ""
    
    var body: some View {
        
        
        HStack {
            Spacer()
            Button(action: {self.bleManager.connect(periphConn: periph)}, label: {
                Text("Connect")
            }).buttonStyle(.borderedProminent)
            Text("\(periph.name), \(periph.rssi)")
                .font(.system(size: 12, weight: .light, design: .default))
            Button(action: {self.bleManager.disconnect(periphConn: periph)}, label: {
                Text("Disconnect")
            }).buttonStyle(.borderedProminent)
            Spacer()
        }
        
        ScrollView {
            HStack {
                Text("Portal Service:")
                    .font(.system(size: 12, weight: .light, design: .default))
                Spacer()
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
                Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "B0730007-6604-4CA1-A5A4-98864F059E4A", payload: 1)}, label: { Text("Disc. LCs")})
                    .buttonStyle(.bordered)
                Button(action: {self.bleManager.readCharacteristicFromString(charString: "B0730013-6604-4CA1-A5A4-98864F059E4A")}, label: { Text("Read LCs")})
                    .buttonStyle(.bordered)
            }
            
            HStack {
                Text("Last Pressed")
                TextField("LastPressed", text: $global.lastPressed)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                TextField("LastType", text: $global.lastType)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
            }
            
            HStack {
                Button(action: {self.bleManager.writeCharacteristicFromHexString(charString: "B0730014-6604-4CA1-A5A4-98864F059E4A", hexString: global.kvpData)}, label: { Text("Write Kvp")})
                    .buttonStyle(.bordered)
                TextField("Kvp data", text: $global.kvpData)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
            }
            
// Zone Names
//            HStack{
//                Button(action: {self.bleManager.readCharacteristicFromString(charString: "B073000A-6604-4CA1-A5A4-98864F059E4A")}, label: { Text("Read ZoneNames")})
//                Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "B073000C-6604-4CA1-A5A4-98864F059E4A", payload: 1)}, label: { Text("Start ZoneLC")})
//                Button(action: {self.bleManager.readCharacteristicFromString(charString: "B073000D-6604-4CA1-A5A4-98864F059E4A")}, label: { Text("Read ZoneLC")})
//            }
            
// Zone of Interest
//            HStack {
//                Button(action: {self.bleManager.readCharacteristicFromString(charString: "B073000B-6604-4CA1-A5A4-98864F059E4A")}, label: { Text("Read ZOI")})
//
//                TextField("ZoneOfInterest", text: $global.zoneOfInterest)
//                    .multilineTextAlignment(.center)
//                    .textFieldStyle(.roundedBorder)
//                    .frame(width: 150)
//
//                Button(action: {self.bleManager.writeCharacteristicFromString(charString: "B073000B-6604-4CA1-A5A4-98864F059E4A", textString: global.zoneOfInterest)}, label: { Text("Write ZOI")})
//            }
            
            
            
            
            HStack {
                Text("LC Service:")
                    .font(.system(size: 12, weight: .light, design: .default))
                Spacer()
            }
            HStack {
                Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "674F0006-8B40-11EC-A8A3-0242AC120002", payload: 1)}, label: { Text("Toggle")}).buttonStyle(.bordered)
                Picker("Select LC", selection: $selection) {
                    ForEach(global.lcList, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: selection) { value in
                    self.bleManager.writeCharacteristicFromInt32(charString: "674F0002-8B40-11EC-A8A3-0242AC120002", payload: UInt32(value, radix: 16) ?? 0)
                }
                Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "674F0003-8B40-11EC-A8A3-0242AC120002", payload: 4)}, label: { Text("LCSync")}).buttonStyle(.bordered)
            }
            
            
            
            
            HStack {
                Button(action: {self.bleManager.readCharacteristicFromString(charString: "674F0002-8B40-11EC-A8A3-0242AC120002")}, label: { Text("Read")})
                
                TextField("LCofInterest", text: $global.lcOfInterest)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                
                Button(action: {self.bleManager.writeCharacteristicFromInt32(charString: "674F0002-8B40-11EC-A8A3-0242AC120002", payload: UInt32(global.lcOfInterest, radix: 16) ?? 0)}, label: { Text("Write")})
            }
        
            HStack {
                Button(action: {self.bleManager.readCharacteristicFromString(charString: "674F0003-8B40-11EC-A8A3-0242AC120002")}, label: { Text("Read")})
                
                TextField("LcData", text: $global.lcData)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 150)
                
                Button(action: {self.bleManager.writeCharacteristicFromInt8(charString: "674F0003-8B40-11EC-A8A3-0242AC120002", payload: UInt8(global.lcData, radix: 16) ?? 0)}, label: { Text("Write")})
            }
            
        }.frame(minHeight: 100)
        
        
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
        }.frame(minHeight: 100, maxHeight: 150)
        
        Spacer()
        
    }
}

//struct PeriphDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeriphDetail(periph: {})
//    }
//}
