//
//  PhoneLightRow.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

struct PhoneLightRow: View {
    @EnvironmentObject var userData: UserData
    
    var phoneLight: PhoneLight
    
    
    
    var phoneLightIndex: Int {
        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id})!
    }
    
    
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(phoneLight.deviceName)
                    .fontWeight(.bold)
                    
                Text(phoneLight.productName)
                    .font(.subheadline)
                    .padding(.zero)
            }
            Spacer()
            Toggle(isOn: $userData.phoneLight[phoneLightIndex].outputState) {
                Text("")
            }.onChange(of: userData.phoneLight[phoneLightIndex].outputState, perform: { value in
                print("\(userData.phoneLight[phoneLightIndex].deviceName)'s new value is \(userData.phoneLight[phoneLightIndex].outputState)")
            })
            if (userData.phoneLight[phoneLightIndex].outputState) {
                Text("ON")
            }
            else {
                Text("OFF")
            }
//            .onChange(of: userData.phoneLight[phoneLightIndex].outputState, perform: { value in
//                print("new value \(value)")
//            })
                //.labelsHidden()
//                .onTapGesture {
//                    print("new state \(userData.phoneLight[phoneLightIndex].outputState)")
//                }
                
//            Button(action: {
//                print("Toggle tapped! \(phoneLight.deviceName)")
//                self.userData.phoneLight[phoneLightIndex].outputState.toggle()
//                print(self.userData.phoneLight[phoneLightIndex].outputState)
//
//            }) {
//                HStack {
//                    Image(systemName: "lightbulb")
//                        .font(.title)
//                    if (phoneLight.outputState == true) {
//                        Text("On")
//
//                    } else {
//                        Text("Off")
//                            .fontWeight(.semibold)
//                            .font(.subheadline)
//                    }
//
//                }
//                .frame(minWidth: 0, maxWidth: 90, maxHeight: 10)
//                .padding()
//                .foregroundColor(.white)
//                .background(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.yellow]), startPoint: .leading, endPoint: .trailing))
//                .cornerRadius(40)
//            }
            
        }.background(userData.phoneLight[phoneLightIndex].outputState ? Color.orange : Color.purple)
        
       
    }
}

struct PhoneLightRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PhoneLightRow(phoneLight: phoneLightData[0]).environmentObject(UserData())
            PhoneLightRow(phoneLight: phoneLightData[1]).environmentObject(UserData())
            PhoneLightRow(phoneLight: phoneLightData[2]).environmentObject(UserData())
        }
    }
}
