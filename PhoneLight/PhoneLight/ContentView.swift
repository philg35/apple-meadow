//
//  ContentView.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            List(userData.phoneLight) { (phonelight2) -> PhoneLightRow in
                PhoneLightRow(phoneLight: phonelight2)
            }.navigationBarTitle(Text("Lights"), displayMode: .large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
