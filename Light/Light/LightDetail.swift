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
        "023-fan",
        "005-bathtub",
        "028-dish",
        "006-shower",
        "015-sofa",
        "035-washing-machine",
        "011-faucet",
        "012-book-shelf",
        "027-cutlery",
        "016-chandelier",
        "034-kitchen",
        "025-desk-lamp",
        "026-dining-table",
        "030-glass",
        "017-hanger",
        "032-toilet",
        "021-toaster",
        "031-plug",
        "019-freezer",
        "014-light-bulb",
        "033-flowerpot",
        "020-desk",
        "002-blender",
        "029-dresser",
        "010-trash",
        "001-air-conditioner",
        "022-frying-pan",
        "024-window",
        "004-basin",
        "018-wardrobe",
        "013-book-shelf-1",
        "009-bedroom",
        "036-microwave",
        "003-armchair",
        "008-carpet",
        "007-towel",
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
