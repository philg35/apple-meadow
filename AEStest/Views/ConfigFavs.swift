//
//  ConfigFavs.swift
//  AEStest
//
//  Created by Philip Gross on 9/7/22.
//

import SwiftUI

struct ConfigFavs: View {
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack {
            Button("Save") {
                print("save favorites now")
                var favoriteList : [String] = []
                for d in userData.allDeviceData {
                    if d.hasOutput {
                        favoriteList.append(d.deviceId)
                    }
                }
                let defaults = UserDefaults.standard
                defaults.set(favoriteList, forKey: "favoriteList")
                userData.favoritesList = favoriteList
                print("saving favoriteList=", userData.favoritesList)
            }
            .buttonStyle(BlueButton())
            NavigationView {
                List(userData.allDeviceData) { phonelight2 in
                    
                    ConfigFavsRow(deviceData: phonelight2)
                    //}.background(Color("RowBackground"))
                    //.frame(height: 25)
                    
                }//.navigationBarTitle(Text("Config Favs"), displayMode: .inline)
                
            }.padding(-15.0)
        }
    }
}

struct ConfigFavs_Previews: PreviewProvider {
    static var previews: some View {
        ConfigFavs()
    }
}
