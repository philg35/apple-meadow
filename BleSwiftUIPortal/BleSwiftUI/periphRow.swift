//
//  periphRow.swift
//  BleSwiftUI
//
//  Created by Philip Gross on 9/11/21.
//  Copyright © 2021 Philip Gross. All rights reserved.
//

import SwiftUI

struct PeriphRow: View {
    var periph : Peripheral
    var body: some View {
        HStack {
            Text("\(periph.name)")
            Text("\(periph.rssi)")
        }
    }
}

//struct periphRow_Previews: PreviewProvider {
//    static var previews: some View {
//        periphRow()
//    }
//}
