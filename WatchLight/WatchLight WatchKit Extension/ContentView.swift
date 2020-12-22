//
//  ContentView.swift
//  WatchLight WatchKit Extension
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
        Text("Hello, World!")
            .padding()
            List {
                
                Text("Living");
                    
                
                Text("Kitchen");
                Text("Fireplace")
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
