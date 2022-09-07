//
//  FavoriteDetail.swift
//  AEStest
//
//  Created by Philip Gross on 9/6/22.
//


import SwiftUI

struct FavoriteDetail: View {
    
    @EnvironmentObject var userData: UserData
    var deviceData: DeviceDataStruct
    
//    var phoneLightIndex: Int {
//        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id}) ?? 0
//    }
    
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading) {
                Text("\(deviceData.deviceName)").font(.headline)
                Text("Product name: \(deviceData.productName)").font(.subheadline)
                Text("Serial number: \(deviceData.deviceId)").font(.subheadline)
            }.padding()
            .navigationBarTitle(Text("Favorite Detail"), displayMode: .inline)
        }
    }
}

struct LightDetail_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteDetail(deviceData: AllDeviceData[0]).environmentObject(UserData())
    }
}

extension String: Identifiable {            // needed to make list out of array of strings
    public var id: String {
        self
    }
}

