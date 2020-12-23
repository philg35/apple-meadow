//
//  ContentView.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct ContentView: View {
    
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            VStack {
                
                Button(action: {
                    print("Xml tapped!")
                    userData.phoneLight.removeAll()
                    
                    let xml = GetXml()
                    xml.read()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // 2.0 seconds
                        var index = 0
                        for p in xml.deviceArray {
                            print("parent", p.parentName)
                            for d in p.devicesOnPort {
                                print("device", d.label, index)
                                
                                userData.phoneLight.append(PhoneLight(id: index, deviceName: d.label, productName: d.model, imageName: "none", occState: false, outputState: false, level: 100))
                                index += 1
                            }
                        }
                    }
                    
                    
                }) {
                    HStack {
                        Image(systemName: "star.fill")
                            .font(.title)
                        Text("Xml")
                            .fontWeight(.semibold)
                            .font(.title)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(40)
                }
                
                
                List(userData.phoneLight) { (phonelight2) -> PhoneLightRow in
                    PhoneLightRow(phoneLight: phonelight2)
                }
            }.navigationBarTitle(Text("Lights"), displayMode: .large)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
