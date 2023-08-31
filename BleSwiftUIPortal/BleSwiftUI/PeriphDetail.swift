//
//  PeriphDetail.swift
//  BleSwiftUI
//
//  Created by Philip Gross on 9/11/21.
//  Copyright © 2021 Philip Gross. All rights reserved.
//

import SwiftUI

struct PeriphDetail: View {
    
    var periph : Peripheral
    @ObservedObject var bleManager: BLEManager
    @State private var portalname: String = "Phils portal"
    
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
        Button(action: {self.bleManager.readCharacteristicFromString(charString: "B0730002-6604-4CA1-A5A4-98864F059E4A")}, label: { Text("Read Name")})
        Button(action: {self.bleManager.writeCharacteristicFromString(charString: "B0730002-6604-4CA1-A5A4-98864F059E4A", textString: portalname)}, label: { Text("Write Name")})
        
        TextField("PortalName", text: $portalname)
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .frame(width: 250)
            
        VStack {
            ScrollViewReader { proxy in
                   ScrollView {
                       Text("\(periph.readOutput)")
                           .id(1)            // this is where to add an id
                           .multilineTextAlignment(.leading)
                           .font(.system(size: 10, weight: .light, design: .default))
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
