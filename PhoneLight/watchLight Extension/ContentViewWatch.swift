//
//  ContentView.swift
//  watchLight Extension
//
//  Created by Philip Gross on 12/22/20.
//

import SwiftUI

struct ContentViewWatch: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            List {
                // device row
                ForEach(userData.phoneLight) { phonelight in
                    PhoneLightRow(phoneLight: phonelight)
                }
            }
        }
    }
}

struct ContentViewWatch_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWatch().environmentObject(UserData())
    }
}
