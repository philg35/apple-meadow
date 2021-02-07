//
//  LightImage.swift
//  Light
//
//  Created by Philip Gross on 1/1/21.
//

import SwiftUI

struct LightImage: View {
    
    @EnvironmentObject var userData: UserData
    var phoneLight: PhoneLight
    
    var phoneLightIndex: Int {
        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id}) ?? 0
    }
    @State private var selectedImage = 0
    var items = [
        "air-conditioner",
        "armchair",
        "basin",
        "bathtub",
        "bedroom",
        "blender",
        "book-shelf-1",
        "book-shelf",
        "carpet",
        "chandelier",
        "cutlery",
        "desk-lamp",
        "desk",
        "dining-table",
        "dish",
        "dresser",
        "fan",
        "faucet",
        "fireplace",
        "flowerpot",
        "footprints",
        "freezer",
        "frying-pan",
        "glass",
        "hanger",
        "kitchen",
        "lantern",
        "light-bulb",
        "microwave",
        "plug",
        "shower",
        "sofa",
        "toaster",
        "toilet",
        "towel",
        "trash",
        "wardrobe",
        "washing-machine",
        "window",
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                Text(phoneLight.deviceName)
                    .font(.system(size: 35, weight: .bold, design: .default))
                Picker(selection: $selectedImage, label: Text("Select Image")){
                    ForEach(0 ..< items.count) {
                        Text(self.items[$0]).tag($0)
                    }
                }
                Text("You selected: \(items[selectedImage])")
                Image(items[selectedImage])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                Button(action: {
                    userData.phoneLight[phoneLightIndex].imageName = items[selectedImage]
                    userData.saveImage(deviceId: phoneLight.deviceId, imageName: self.items[selectedImage])
                }, label: {
                    Text("Save Image")
                })
            }
        }
    }
}

struct LightImage_Previews: PreviewProvider {
    static var previews: some View {
        LightImage(phoneLight: phoneLightData[0]).environmentObject(UserData())
    }
}
