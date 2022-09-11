//
//  ConfigIp.swift
//  AEStest
//
//  Created by Philip Gross on 9/6/22.
//

import SwiftUI

struct ConfigIp: View {
    @EnvironmentObject var userData: UserData
    @State private var newIP: String = ""
    
    var body: some View {
        VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            Spacer()
                .frame(height: 50)
            //Text("Current ipAddress is \(ipAddress)")
            Spacer()
                .frame(height: 50)
            HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Spacer()
                TextField("Enter your IP", text: $newIP)
                    .padding(.leading, 40)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                Button("Add") {
                    print("adding ipaddress", newIP)
                    let defaults = UserDefaults.standard
                    defaults.set(newIP, forKey: "defaultIP")
                    userData.changeIpAddress(ipaddr: newIP)
                }
                .padding(.trailing, 50)
            })
            Spacer()
                .frame(height: 50)
            Text("New ipAddress is \(newIP)")
            Spacer()
        })
        
        
    }
}

struct ConfigIp_Previews: PreviewProvider {
    static var previews: some View {
        ConfigIp()
    }
}
