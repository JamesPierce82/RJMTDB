//
//  AppDelegate.swift
//  RJMTDB
//
//  Created by James Pierce on 2017-12-27.
//  Copyright © 2017 James Pierce. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        if let tabBarController = window?.rootViewController as? UITabBarController,
            let viewControllers = tabBarController.viewControllers {
            for viewController in viewControllers {
                guard let navVC = viewController as? UINavigationController,
                    var mocVC = navVC.viewControllers[0] as? MOCViewControllerType
                    else { continue }
                
                mocVC.managedObjectContext = persistentContainer.viewContext
            }
        }
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let managedObjectContext = persistentContainer.viewContext
        guard let allMovies = try? managedObjectContext.fetch(fetchRequest) else {
            completionHandler(.failed)
            return
        }
        
        let queue = DispatchQueue(label: "movieDBQueue")
        let group = DispatchGroup()
        let helper = SearchHelper()
        var dataChanged = false
        
        for movie in allMovies {
            queue.async(group: group) {
                group.enter()
                helper.fetchRating(forMovieId: movie.remoteId) { id, popularity, overview, poster_path, release_date in
                    guard let popularity = popularity, popularity != movie.popularity else {
                            group.leave()
                            return
                    }
                    
                    dataChanged = true
                    
                    managedObjectContext.persist {
                        movie.popularity = popularity
                        group.leave()
                    }
                }
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if dataChanged {
                completionHandler(.newData)
            } else {
                completionHandler(.noData)
            }
        }
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
        persistentContainer.saveContextIfNeeded()
    }

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "RJMTDB")
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

