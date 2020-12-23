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
            List {
                // button
                Button(action: {
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
                    .frame(maxWidth: 150, maxHeight: 45)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(40)
                }
                
                // device row
                ForEach(userData.phoneLight) { phonelight in
                    PhoneLightRow(phoneLight: phonelight)
                }
            }
        }
    }
}

struct ContentViewWatch_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWatch().environmentObject(UserData())
    }
}
