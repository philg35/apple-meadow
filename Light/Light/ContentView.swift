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
//        NavigationView {
//            VStack {
//
//                List(userData.phoneLight) { (phonelight2) -> LightRow in
//                    LightRow(phoneLight: phonelight2)
//                }
//
//                Spacer()
//
//                Picker(selection: $selectedFrameworkIndex, label: Image("")) {
//                    ForEach(self.items, id: \.self) { item in
//                        Image(item)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                    }
//                }
//                .background (Color.white)
//                .frame(maxHeight: 100)
//
//            }.navigationBarTitle(Text("Lights"), displayMode: .large)
//        }
        
        VStack {
            NavigationView {
                List(userData.phoneLight) { phonelight2 in
                    NavigationLink(destination: LightDetail(phoneLight: phonelight2)) {
                        LightRow(phoneLight: phonelight2)
                    }
                    
                }
            }
            
            Spacer()
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(UserData())
    }
}
