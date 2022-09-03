//
//  ContentView.swift
//  AEStest
//
//  Created by Philip Gross on 8/27/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var ipConn = IPConnection()
    
    
    var body: some View {
        VStack {
        Text("AES test")
            .padding()
            
            
        Button(action: {
            ipConn.send(nlightString: "a5000003fa00fb031b107901010038ee")
        }) {
            Text("On")
        }
        
        
        Button(action: {
            ipConn.send(nlightString: "a5000003fa00fb031b10790102003bee")
        }) {
            Text("Off")
        }
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



