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
//                Button(action: {
//                    print("Xml tapped!")
//                    //userData.phoneLight.removeAll()
//                    userData.loadData()
//                }) {
//                    HStack {
//                        Image(systemName: "star.fill")
//                            .font(.title)
//                        Text("Xml")
//                            .fontWeight(.semibold)
//                            .font(.title)
//                    }
//                    .padding()
//                    .frame(maxWidth: 150, maxHeight: 45)
//                    .foregroundColor(.white)
//                    .background(Color.blue)
//                    .cornerRadius(40)
//                }
                
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
