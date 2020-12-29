//
//  LightApp.swift
//  Light WatchKit Extension
//
//  Created by Philip Gross on 12/29/20.
//

import SwiftUI

@main
struct LightApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
