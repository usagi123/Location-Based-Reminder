//
//  AppDelegate.swift
//  Location Based Reminder
//
//  Created by Mai Pham Quang Huy on 8/20/18.
//  Copyright © 2018 Mai Pham Quang Huy. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        // Do a quick check to see if you've provided an API key, in a real app you wouldn't need this
        // but for the demo it means we can provide a better error message if you haven't.
        if kMapsAPIKey.isEmpty || kPlacesAPIKey.isEmpty {
            // Blow up if API keys have not yet been set.
            let bundleId = Bundle.main.bundleIdentifier!
            let msg = "Configure API keys inside SDKDemoAPIKey.swift for your  bundle `\(bundleId)`, " +
            "see README.GooglePlacePickerDemos for more information"
            fatalError(msg)
        }
        
        // Provide the Places API with your API key.
        GMSPlacesClient.provideAPIKey(kPlacesAPIKey)
        // Provide the Maps API with your API key. We need to provide this as well because the Place
        // Picker displays a Google Map.
        GMSServices.provideAPIKey(kMapsAPIKey)
        
        // Log the required open source licenses! Yes, just logging them is not enough but is good for
        // a demo.
        print(GMSPlacesClient.openSourceLicenseInfo())
        print(GMSServices.openSourceLicenseInfo())
        
        // Construct a window and the split split pane view controller we are going to embed our UI in.
        let window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = PickAPlaceViewController()
        let splitPaneViewController = SplitPaneViewController(rootViewController: rootViewController)
        
        // Wrap the split pane controller in a inset controller to get the map displaying behind our
        // content on iPad devices.
        let mapController = BackgroundMapViewController()
        rootViewController.mapViewController = mapController
        let insetController = InsetViewController(backgroundViewController: mapController,
                                                  contentViewController: splitPaneViewController)
        window.rootViewController = insetController
        
        // Make the window visible and allow the app to continue initialization.
        window.makeKeyAndVisible()
        self.window = window
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FavoriteSongs")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

