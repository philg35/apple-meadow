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
        
        NavigationView {
            List(userData.allDeviceData) { phonelight2 in
                
                ConfigFavsRow(deviceData: phonelight2)
                //}.background(Color("RowBackground"))
                //.frame(height: 25)
                
            }.navigationBarTitle(Text("Config Favs"), displayMode: .inline)
            
        }.padding(-15.0)
        
        
        
    }
}

struct ConfigFavs_Previews: PreviewProvider {
    static var previews: some View {
        ConfigFavs()
    }
}
