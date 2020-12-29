//
//  LightApp.swift
//  Light
//
//  Created by Philip Gross on 12/29/20.
//

import SwiftUI

@main
struct LightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(UserData())
        }
    }
}
