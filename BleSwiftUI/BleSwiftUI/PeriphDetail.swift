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
        Text("\(periph.manufData)")
        Button(action: {self.bleManager.connect(periphConn: periph)}, label: {
            Text("Connect")
        })
    }
}

//struct PeriphDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PeriphDetail(periph: {})
//    }
//}
