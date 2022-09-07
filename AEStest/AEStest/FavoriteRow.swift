//
//  FavoriteRow.swift
//  AEStest
//
//  Created by Philip Gross on 9/6/22.
//

import SwiftUI

struct FavoriteRow: View {
    @EnvironmentObject var userData: UserData
    
    var deviceData: DeviceDataStruct
    
    var body: some View {
        if (userData.allDeviceData.count > 0) {
            HStack {
                
                VStack(alignment: .leading, spacing: 0){
                    Text(deviceData.deviceName)
                        .fontWeight(.bold)
                        .frame(width: 135, alignment: .leading)
                    
                    Text(deviceData.productName)
                        .font(.system(size: 12))
                    
                }.frame(width: 135, alignment: .leading)
                
                Spacer()
                
                HStack {
                    
//                    Spacer()
//                    if (userData.phoneLight.indices.contains(phoneLightIndex)) {
//                        Toggle(isOn: $userData.phoneLight[phoneLightIndex].outputState) {
//                            Text("")
//                        }
//                        .frame(minWidth: 0, idealWidth: 20, maxWidth: 30, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: 20, maxHeight: 20, alignment: .center)
//                        .onChange(of: userData.phoneLight[phoneLightIndex].outputState, perform: { value in
//                            print("\(userData.phoneLight[phoneLightIndex].deviceName)'s new value is \(userData.phoneLight[phoneLightIndex].outputState)")
//                            userData.didPressSwitch(deviceID: userData.phoneLight[phoneLightIndex].deviceId, newState: userData.phoneLight[phoneLightIndex].outputState)
//                        })
//                        .padding(.trailing, 20)
//                    }
//                    Spacer()
//                    if (phoneLight.hasDim) {
//                        Text(String(phoneLight.level))
//                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                            .frame(width: 30)
//                    }
//                    else {
//                        Text("")
//                            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
//                            .frame(width: 30)
//                    }
                }
            }
        }
    }
}

struct FavoriteRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            FavoriteRow(deviceData: AllDeviceData[0]).environmentObject(UserData())
            FavoriteRow(deviceData: AllDeviceData[1]).environmentObject(UserData())
            FavoriteRow(deviceData: AllDeviceData[2]).environmentObject(UserData())
        }
    }
}
