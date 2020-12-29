//
//  ContentView.swift
//  Light
//
//  Created by Philip Gross on 12/29/20.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
