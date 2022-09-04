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
    @StateObject var ipConn = IPConnection(ipaddress: "10.0.0.251")
    var np = NlightPacket()
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                Text("Fan")
                    .padding()
                    .foregroundColor(Color.blue)
                
                HStack {
                    Spacer()
                    
                    Button("On") {
                        let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "79", payload: "010100")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                    Button("Off") {
                        let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "79", payload: "010200")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                }
                
                Text("Kitchen Table")
                    .padding()
                    .foregroundColor(Color.blue)
                
                HStack {
                    Spacer()
                    
                    Button("On") {
                        let p = np.CreatePacket(dest: "00000406", src: "00fb031b", subj: "79", payload: "010100")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                    Button("Off") {
                        let p = np.CreatePacket(dest: "00000406", src: "00fb031b", subj: "79", payload: "010200")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                Button("curtsy fan") {
                    let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "BA", payload: "")
                    print("packet=", p)
                    ipConn.send(nlightString: p)
                }
                .buttonStyle(BlueButton())
                
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



