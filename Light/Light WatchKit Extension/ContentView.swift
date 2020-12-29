//
//  ContentView.swift
//  Light WatchKit Extension
//
//  Created by Philip Gross on 12/29/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack {
            List(userData.phoneLight) { (phonelight2) -> LightRow in
                LightRow(phoneLight: phonelight2)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
