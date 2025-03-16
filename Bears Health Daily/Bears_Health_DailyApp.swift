//
//  Bears_Health_DailyApp.swift
//  Bears Health Daily
//
//  Created by xuanxuan on 12/19/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct Bears_Health_DailyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject private var viewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
              .environmentObject(viewModel)
        }
    }
}
