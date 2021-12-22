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
    
    var body: some View {
        Text("\(periph.name)").font(.headline)
        Text("\(periph.rssi)")
        Text("\(periph.id)")
        HStack {
        Button(action: {self.bleManager.connect(periphConn: periph)}, label: {
            Text("Connect")
        })
            Button(action: {self.bleManager.disconnect(periphConn: periph)}, label: {
                Text("Disconnect")
            })
        }
        Text("Services:")
        ScrollView {
        Text("\(periph.serviceList)")
            .multilineTextAlignment(.leading)
            //.padding(.leading, 10)
        }
        
        Text("Characteristics:")
        ScrollView {
        Text("\(periph.characteristicList)")
            .multilineTextAlignment(.leading)
            //.padding(.leading, 10)
        }
    }
}

//struct PeriphDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeriphDetail(periph: {})
//    }
//}
