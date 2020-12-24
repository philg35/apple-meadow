//
//  PhoneLightRow.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct PhoneLightRow: View {
    @EnvironmentObject var userData: UserData
    
    var phoneLight: PhoneLight
    
    
    
    var phoneLightIndex: Int {
        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id}) ?? 0
    }
    
    
    
    var body: some View {
        if (userData.phoneLight.count > 0) {
            HStack{
                VStack(alignment: .leading){
                    Text(phoneLight.deviceName)
                        .fontWeight(.bold)
                    
                    Text(phoneLight.productName)
                        .font(.subheadline)
                        .padding(.zero)
                    
                    //Text("ID \(phoneLight.id)")
                }
                Spacer()
                if (userData.phoneLight.indices.contains(phoneLightIndex)) {
                    
                    Toggle(isOn: $userData.phoneLight[phoneLightIndex].outputState) {
                        Text("")
                    }.onChange(of: userData.phoneLight[phoneLightIndex].outputState, perform: { value in
                        print("\(userData.phoneLight[phoneLightIndex].deviceName)'s new value is \(userData.phoneLight[phoneLightIndex].outputState)")
                    })
                }
                
                //            if (userData.phoneLight[phoneLightIndex].outputState) {
                //                Text("ON")
                //            }
                //            else {
                //                Text("OFF")
                //            }
            }//.background(userData.phoneLight[phoneLightIndex].outputState ? Color.orange : Color.purple)
        }
    }
}

struct PhoneLightRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PhoneLightRow(phoneLight: phoneLightData[0]).environmentObject(UserData())
            PhoneLightRow(phoneLight: phoneLightData[1]).environmentObject(UserData())
            PhoneLightRow(phoneLight: phoneLightData[2]).environmentObject(UserData())
        }
    }
}
