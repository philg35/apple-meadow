//
//  LightDetail.swift
//  Light
//
//  Created by Philip Gross on 12/31/20.
//

import SwiftUI

struct LightDetail: View {
    
    @EnvironmentObject var userData: UserData
    var phoneLight: PhoneLight
    var phoneLightIndex: Int {
        userData.phoneLight.firstIndex(where: { $0.id == phoneLight.id}) ?? 0
    }
    @State private var selectedImage = 0
    var items = [
        "001-air-conditioner",
        "002-blender",
        "003-armchair",
        "004-basin",
        "005-bathtub",
        "006-shower",
        "007-towel",
        "008-carpet",
        "009-bedroom",
        "010-trash",
        "011-faucet",
        "012-book-shelf",
        "013-book-shelf-1",
        "014-light-bulb",
        "015-sofa",
        "016-chandelier",
        "017-hanger",
        "018-wardrobe",
        "019-freezer",
        "020-desk",
        "021-toaster",
        "022-frying-pan",
        "023-fan",
        "024-window",
        "025-desk-lamp",
        "026-dining-table",
        "027-cutlery",
        "028-dish",
        "029-dresser",
        "030-glass",
        "031-plug",
        "032-toilet",
        "033-flowerpot",
        "034-kitchen",
        "035-washing-machine",
        "036-microwave",
        "fireplace",
        "lantern",
        "footprints",
    ]
    
    var body: some View {
        
        VStack {
            Image(phoneLight.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Text("\(phoneLight.deviceName)").font(.headline)
            Text("Product name: \(phoneLight.productName)").font(.subheadline)
            Text("Serial number: \(phoneLight.deviceId)").font(.subheadline)
            Button(action: {
                print("saving", selectedImage, self.items[selectedImage])
                userData.saveImage(deviceId: phoneLight.deviceId, imageName: self.items[selectedImage])
                userData.phoneLight[phoneLightIndex].imageName = items[selectedImage]
            }, label: {
                Text("Save Image")
            })
            
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
        }
    }
}

struct LightDetail_Previews: PreviewProvider {
    static var previews: some View {
        LightDetail(phoneLight: phoneLightData[0]).environmentObject(UserData())
    }
}
