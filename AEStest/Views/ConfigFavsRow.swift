//
//  ConfigFavsRow.swift
//  AEStest
//
//  Created by Philip Gross on 9/7/22.
//

import SwiftUI

struct ConfigFavsRow: View {
    @EnvironmentObject var userData: UserData
    
    var deviceData: DeviceDataStruct
    
    var allDeviceDataIndex: Int {
        userData.allDeviceData.firstIndex(where: { $0.id == deviceData.id}) ?? 0
    }
    
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
                    Button("ID") {
                        userData.didPressCurtsy(deviceID: deviceData.deviceId)
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                    Toggle("Fav", isOn: $userData.allDeviceData[allDeviceDataIndex].hasOutput)
                        .toggleStyle(CheckToggleStyle())
                    
                    Spacer()
                }
            }
        }
    }
}

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {
                configuration.label
            } icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .accentColor : .secondary)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ConfigFavsRow_Previews: PreviewProvider {
    static var previews: some View {
        ConfigFavsRow(deviceData: AllDeviceData[0]).environmentObject(UserData())
    }
}
