//
//  LightRow.swift
//  Light
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct LightRow: View {
    @EnvironmentObject var userData: UserData
    
    var phoneLight: PhoneLight
    
    var phoneLightIndex: Int {
        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id}) ?? 0
    }
    
    var body: some View {
        if (userData.phoneLight.count > 0) {
            HStack{
                Image(phoneLight.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading){
                    
                    Text(phoneLight.deviceName)
                        .fontWeight(.bold)
                    HStack {
                        Text(phoneLight.productName)
                            .font(.system(size: 12))
                        
                        Text("(" + phoneLight.deviceId + ")")
                            .font(.system(size: 8))
                    }
                }.frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, maxWidth: 160, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 20, maxHeight: 20, alignment: .leading)
                
                Spacer()
                if (phoneLight.hasOcc == true) {
                    if (phoneLight.occState == true) {
                        Image(systemName: "figure.walk").foregroundColor(.green)
                    }
                    else {
                        Image(systemName: "zzz").foregroundColor(.red)
                    }
                }
                Spacer()
                if (userData.phoneLight.indices.contains(phoneLightIndex)) {
                    
                    Toggle(isOn: $userData.phoneLight[phoneLightIndex].outputState) {
                        Text("")
                    }
                    .frame(minWidth: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealWidth: 20, maxWidth: 30, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 20, maxHeight: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .onChange(of: userData.phoneLight[phoneLightIndex].outputState, perform: { value in
                        print("\(userData.phoneLight[phoneLightIndex].deviceName)'s new value is \(userData.phoneLight[phoneLightIndex].outputState)")
                        userData.didPressSwitch(deviceID: userData.phoneLight[phoneLightIndex].deviceId, newState: userData.phoneLight[phoneLightIndex].outputState)
                    })
                    .padding(.trailing, 20)
                }
            }
        }
    }
}

struct PhoneLightRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            LightRow(phoneLight: phoneLightData[0]).environmentObject(UserData())
//            LightRow(phoneLight: phoneLightData[1]).environmentObject(UserData())
        }
    }
}
