//
//  AppDelegate.swift
//  Canopy
//
//  Created by syxc on 2026-01-08.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var crashBufferTree: CrashBufferTree?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupCanopy()
        return true
    }

    private func setupCanopy() {
        #if DEBUG
        Canopy.plant(DebugTree())
        #endif

        crashBufferTree = CrashBufferTree(maxSize: 50)
        Canopy.plant(crashBufferTree!)

        Canopy.v("Canopy initialized with DebugTree and CrashBufferTree")
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
