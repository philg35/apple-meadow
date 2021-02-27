//
//  ContentView.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

var ipAddr = "10.0.0.251"
struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            List(userData.phoneLight) { phonelight2 in
                NavigationLink(destination: LightDetail(phoneLight: phonelight2)) {
                    LightRow(phoneLight: phonelight2)
                }.background(Color("RowBackground"))
                .frame(height: 25)
                .padding(-15.0)
            }.navigationBarTitle(Text("\(ipAddr)"), displayMode: .large)
            .navigationBarItems(leading: HStack {
                    NavigationLink(destination: LightConfig(ipAddress: ipAddr)) {
                        Text("Config IP") 
                    }
            },                  trailing: HStack {
                Button("Load") {
                    userData.getMqtt()
                }
            }
            )
        }.padding(-15.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
