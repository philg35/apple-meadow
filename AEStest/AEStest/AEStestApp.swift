//
//  AEStestApp.swift
//  AEStest
//
//  Created by Philip Gross on 8/27/22.
//

import SwiftUI

@main
struct AEStestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(UserData())
        }
    }
}
