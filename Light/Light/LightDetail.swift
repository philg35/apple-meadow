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
            }
            .navigationBarTitle(Text("Light Detail"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    // Actions
                }, label: { Text("Events") }),
                
                trailing: Button(action: {
                    // Actions
                }, label: { Text("Info") }))
        }
    }
}

struct LightDetail_Previews: PreviewProvider {
    static var previews: some View {
        LightDetail(phoneLight: phoneLightData[0]).environmentObject(UserData())
    }
}
