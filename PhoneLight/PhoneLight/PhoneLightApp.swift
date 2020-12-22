//
//  PhoneLightApp.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

@main
struct PhoneLightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(UserData())
        }
    }
}
