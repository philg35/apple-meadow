//
//  ContentView.swift
//  AEStest
//
//  Created by Philip Gross on 8/27/22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    @StateObject var ipConn = IPConnection(ipaddress: "10.0.0.251")
    
    //@StateObject var ipConn = IPConnection(ipaddress: "73.142.174.55")
    let serialNums : [String] = ["00000402", "00000406", "00000405"]
    let timer = Timer.publish(every: 0.5, tolerance: 0.1, on: .main, in: .common).autoconnect()
    @State private var counter = 5
    
    var np = NlightPacket()
    var body: some View {
        
        NavigationView {
            List(userData.allDeviceData) { phonelight2 in
                //NavigationLink(destination: FavoriteDetail(deviceData: phonelight2)) {
                    FavoriteRow(deviceData: phonelight2)
                //}.background(Color("RowBackground"))
                //.frame(height: 25)
                
            }//.navigationBarTitle(Text("\(ipAddr)"), displayMode: .inline)
            .navigationBarItems(leading: HStack {
                NavigationLink(destination: ConfigIp()) {
                    Text("Config IP")
                }
            },                  trailing: HStack {
                NavigationLink(destination: ConfigFavs()) {
                    Text("Config Favs")
                }
            }
            )
        }.padding(-15.0)
    }
    
    
//    var body: some View {
//
//            VStack {
//                Button("Config IP") {
//
//                }
//                .buttonStyle(BlueButton())
//
//                VStack {
//                    Text("Fan")
//                        .padding()
//                        .foregroundColor(Color.blue)
//
//                    HStack {
//
//                        Spacer()
//
//                        Button("On") {
//                            let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "79", payload: "010100")
//                            let r = self.ipConn.send(nlightString: p)
//                            print(r)
//                            counter = 5
//                        }
//                        .buttonStyle(BlueButton())
//
//                        Spacer()
//
//                        Button("Off") {
//                            let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "79", payload: "010200")
//                            let r = self.ipConn.send(nlightString: p)
//                            print(r)
//                            counter = 5
//
//                        }
//                        .buttonStyle(BlueButton())
//
//                        Spacer()
//
//                    }
//                }
//
//                VStack {
//                    Text("Kitchen Table")
//                        .padding()
//                        .foregroundColor(Color.blue)
//
//                    HStack {
//                        Spacer()
//
//                        Button("On") {
//                            let p = np.CreatePacket(dest: "00000406", src: "00fb031b", subj: "79", payload: "010100")
//                            let r = self.ipConn.send(nlightString: p)
//                            print(r)
//                            counter = 5
//                        }
//                        .buttonStyle(BlueButton())
//
//                        Spacer()
//
//                        Button("Off") {
//                            let p = np.CreatePacket(dest: "00000406", src: "00fb031b", subj: "79", payload: "010200")
//                            let r = self.ipConn.send(nlightString: p)
//                            print(r)
//                            counter = 5
//                        }
//                        .buttonStyle(BlueButton())
//
//                        Spacer()
//
//                    }
//                }
//
//                VStack {
//                    Text("Kitchen Island")
//                        .padding()
//                        .foregroundColor(Color.blue)
//
//                    HStack {
//                        Spacer()
//
//                        Button("On") {
//                            let p = np.CreatePacket(dest: "00000405", src: "00fb031b", subj: "79", payload: "010100")
//                            let r = self.ipConn.send(nlightString: p)
//                            print(r)
//                            counter = 5
//                        }
//                        .buttonStyle(BlueButton())
//
//                        Spacer()
//
//                        Button("Off") {
//                            let p = np.CreatePacket(dest: "00000405", src: "00fb031b", subj: "79", payload: "010200")
//                            let r = self.ipConn.send(nlightString: p)
//                            print(r)
//                            counter = 5
//                        }
//                        .buttonStyle(BlueButton())
//
//                        Spacer()
//
//                    }
//                }
//
//                Spacer()
//
//                VStack {
//
//                    Button("curtsy fan") {
//                        let p = np.CreatePacket(dest: "00000402", src: "00fb031b", subj: "BA", payload: "")
//                        let r = ipConn.send(nlightString: p)
//                        print(r)
//                    }
//                    .buttonStyle(BlueButton())
//
//
//                    Button("curtsy table") {
//                        let p = np.CreatePacket(dest: "00000406", src: "00fb031b", subj: "BA", payload: "")
//                        let r = self.ipConn.send(nlightString: p)
//                        print(r)
//                    }
//                    .buttonStyle(BlueButton())
//
//                    Button("curtsy island") {
//                        let p = np.CreatePacket(dest: "00000405", src: "00fb031b", subj: "BA", payload: "")
//                        let r = self.ipConn.send(nlightString: p)
//                        print(r)
//                    }
//                    .buttonStyle(BlueButton())
//
//                }
//            }
//
//        .onReceive(timer) { time in
//            if counter > 0 {
//                counter -= 1
//                //print("The time is now \(time)")
//                for s in serialNums {
//                    let p = np.CreatePacket(dest: s, src: "00fb031b", subj: "74", payload: "15")
//                    let r = self.ipConn.send(nlightString: p)
//                    print(r)
//                }
//            }
//        }
//    }
}

//struct BlueButton: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .padding()
//            .frame(minWidth: 100)
//            .background(configuration.isPressed ? Color.yellow : Color.blue)
//            .foregroundColor(.white)
//            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//            .scaleEffect(configuration.isPressed ? 1.2 : 1)
//                        .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
//
//    }
//}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



