//
//  AppDelegate.swift
//  Noti
//
//  Created by Junroot on 2020/05/12.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    lazy var persistentContainer : NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NotiModels")
        container.loadPersistentStores(completionHandler:{ (NSPersistentStoreDescription, error) in
        if let error = error{
            fatalError("Unresolved error, \(error as NSError).userinfo)")
            }
        })
        return container
    }()
    func saveContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges{
            do{
                try context.save()
            }catch{
                let nserror = error as NSError
                fatalError("unresolveError \(nserror)")
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge], completionHandler: {(didAllow,Error) in
        if !didAllow{
            print("not allow...")
            }
        })
        UNUserNotificationCenter.current().delegate = self
        showNotification()
        return true
    }
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    func showNotification(){
        let content = UNMutableNotificationContent()
        
        content.title = "노티"
        content.body = "오늘 새로운 글이 있는지 확인해보세요!"
        content.badge = 1
        
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year,.month,.day,.hour,.minute,.second], from: now)
        
        components.hour = 18
        components.minute = 15
        let date = gregorian.date(from: components)
        let dailyTrigger = Calendar.current.dateComponents([.hour,.minute,.second], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dailyTrigger, repeats: true)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "localNoti", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
