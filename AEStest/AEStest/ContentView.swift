//
//  ContentView.swift
//  AEStest
//
//  Created by Philip Gross on 8/27/22.
//

import SwiftUI

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(minWidth: 100)
            .background(configuration.isPressed ? Color.yellow : Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
                        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)

    }
}

struct ContentView: View {
    @StateObject var ipConn = IPConnection()
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                Text("AES test")
                    .padding()
                    .foregroundColor(Color.blue)
                
                HStack {
                    
                    Spacer()
                    
                    Button("On") {
                        ipConn.send(nlightString: "a5000003fa00fb031b107901010038ee")
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                    Button("Off") {
                        ipConn.send(nlightString: "a5000003fa00fb031b10790102003bee")
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                }
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



