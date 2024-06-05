//
//  WoodCuttingApp.swift
//  WoodCutting
//
//  Created by Amanada Clouser on 5/18/24.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAppCheck

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    
    let providerFactory = DeviceCheckProviderFactory()
    AppCheck.setAppCheckProviderFactory(providerFactory)

    return true
  }
}

@main
struct WoodCuttingApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
      WindowGroup {
          ContentView()
      }
  }
}

