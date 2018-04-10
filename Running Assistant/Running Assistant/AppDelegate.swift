//
//  AppDelegate.swift
//  Running Assistant
//
//  Created by Balogh Tamás on 2018. 04. 07.
//  Copyright © 2018. Balogh Tamás. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().barTintColor = .black
        let locationManager = LocationManager.shared
        locationManager.requestWhenInUseAuthorization()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataStack.saveContext()
    }
    
}

