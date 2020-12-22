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
            List(userData.phoneLight) { (phonelight2) -> PhoneLightRow in
                PhoneLightRow(phoneLight: phonelight2)
            }
        }
    }
}

struct ContentViewWatch_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWatch()
    }
}
