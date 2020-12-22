//
//  WatchLightApp.swift
//  WatchLight WatchKit Extension
//
//  Created by Philip Gross on 12/21/20.
//

import SwiftUI

@main
struct WatchLightApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
