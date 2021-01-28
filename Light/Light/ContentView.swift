//
//  ContentView.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    init(){
            UITableView.appearance().backgroundColor = .clear
        }
    
    var body: some View {
        NavigationView {
            List(userData.phoneLight) { phonelight2 in
                NavigationLink(destination: LightDetail(phoneLight: phonelight2)) {
                    LightRow(phoneLight: phonelight2).background(Color("RowBackground"))
                }.background(Color("RowBackground"))
                
            }
            .navigationBarTitle(Text("Lights"), displayMode: .large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
