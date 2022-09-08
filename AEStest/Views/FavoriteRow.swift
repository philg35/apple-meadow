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
                    Spacer()
                    Button("On") {
                        userData.didPressSwitch(deviceID: deviceData.deviceId, newState: true)
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                    Button("Off") {
                        userData.didPressSwitch(deviceID: deviceData.deviceId, newState: false)
                    }
                    .buttonStyle(BlueButton())
                }
            }
        }
    }
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 50, maxWidth: 60)
            .font(.system(size: 12))
            .background(configuration.isPressed ? Color.yellow : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)

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
