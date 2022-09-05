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
    let timer = Timer.publish(every: 0.5, tolerance: 0.1, on: .main, in: .common).autoconnect()
    @State private var counter = 5
    
    var np = NlightPacket()
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                
                VStack {
                    Text("Fan")
                        .padding()
                        .foregroundColor(Color.blue)
                    
                    HStack {
                        Spacer()
                        
                        Button("On") {
                            let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "79", payload: "010100")
                            ipConn.send(nlightString: p)
                            counter = 5
                        }
                        .buttonStyle(BlueButton())
                        
                        Spacer()
                        
                        Button("Off") {
                            let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "79", payload: "010200")
                            ipConn.send(nlightString: p)
                            counter = 5
                            
                        }
                        .buttonStyle(BlueButton())
                        
                        Spacer()
                        
                    }
                }
                
                VStack {
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
                }
                
                VStack {
                    Text("Kitchen Island")
                        .padding()
                        .foregroundColor(Color.blue)
                    
                    HStack {
                        Spacer()
                        
                        Button("On") {
                            let p = np.CreatePacket(dest: "00000405", src: "00fb031b", subj: "79", payload: "010100")
                            ipConn.send(nlightString: p)
                        }
                        .buttonStyle(BlueButton())
                        
                        Spacer()
                        
                        Button("Off") {
                            let p = np.CreatePacket(dest: "00000405", src: "00fb031b", subj: "79", payload: "010200")
                            ipConn.send(nlightString: p)
                        }
                        .buttonStyle(BlueButton())
                        
                        Spacer()
                        
                    }
                }
                
                Spacer()
                
                VStack {
                    
                    Button("curtsy fan") {
                        let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "BA", payload: "")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                    
                    Button("curtsy table") {
                        let p = np.CreatePacket(dest: "00000406", src: "00fb031b", subj: "BA", payload: "")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                    Button("curtsy island") {
                        let p = np.CreatePacket(dest: "00000405", src: "00fb031b", subj: "BA", payload: "")
                        ipConn.send(nlightString: p)
                    }
                    .buttonStyle(BlueButton())
                    
                }
                
                
                
            }
            
        }
        .onReceive(timer) { time in
            if counter > 0 {
                counter -= 1
                print("The time is now \(time)")
                //timer.upstream.connect().cancel()
            } //else {
                //print("The time is now \(time)")
            //}
            
            //counter += 1
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



