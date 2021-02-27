//
//  LightConfig.swift
//  Light
//
//  Created by Philip Gross on 2/27/21.
//

import SwiftUI

struct LightConfig: View {
    @EnvironmentObject var userData: UserData
    var ipAddress: String
    @State private var name: String = ""
    
    var body: some View {
        VStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            Spacer()
                .frame(height: 50)
            Text("Current ipAddress is \(ipAddress)")
            Spacer()
                .frame(height: 50)
            HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Spacer()
                TextField("Enter your IP", text: $name)
                    .padding(.leading, 40)
                    .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
                Button("Add") {
                   print("adding ipaddress", name)
                }
                .padding(.trailing, 50)
            })
            Spacer()
                .frame(height: 50)
            Text("New ipAddress is \(name)")
            Spacer()
        })
        
            
    }
}

struct LightConfig_Previews: PreviewProvider {
    static var previews: some View {
        LightConfig(ipAddress: "10.0.0.251")
    }
}
