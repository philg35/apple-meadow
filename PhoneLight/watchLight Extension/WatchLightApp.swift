//
//  PhoneLightApp.swift
//  watchLight Extension
//
//  Created by Philip Gross on 12/22/20.
//

import SwiftUI

@main
struct WatchLightApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentViewWatch().environmentObject(UserData())
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
