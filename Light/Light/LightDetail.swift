//
//  LightDetail.swift
//  Light
//
//  Created by Philip Gross on 12/31/20.
//

import SwiftUI

struct LightDetail: View {
    
    @EnvironmentObject var userData: UserData
    var phoneLight: PhoneLight
    
    var phoneLightIndex: Int {
        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id}) ?? 0
    }
    
    var onTime: Float {
        userData.calcAvgOntime(dict: phoneLight.onTime)
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack(alignment: .leading) {
                HStack {
                    Image(userData.phoneLight[phoneLightIndex].imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    NavigationLink(destination: LightImage(phoneLight: self.phoneLight)) {
                        Text("Edit Image")
                    }
                }
                Text("\(phoneLight.deviceName)").font(.headline)
                Text("Product name: \(phoneLight.productName)").font(.subheadline)
                Text("Serial number: \(phoneLight.deviceId)").font(.subheadline)
                let formattedFloat = String(format: "%.2f", onTime)
                if (!onTime.isNaN) {
                Text("Average on time per day: \(formattedFloat)").font(.headline)
                }
                List(phoneLight.mqttPubs) { mqttRow in
                    RelayPostRow(relayPost: mqttRow)
                }
            }.padding()
            .navigationBarTitle(Text("Light Detail"), displayMode: .inline)
        }
    }
}

struct LightDetail_Previews: PreviewProvider {
    static var previews: some View {
        LightDetail(phoneLight: phoneLightData[0]).environmentObject(UserData())
    }
}

extension String: Identifiable {            // needed to make list out of array of strings
    public var id: String {
        self
    }
}
