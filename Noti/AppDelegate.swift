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
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {(didAllow,Error) in
//        if !didAllow{
//            print("not allow...")
//            }
//        })
        
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) {
            [weak self] granted, error in
              
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string (디바이스 토큰 값을 가져옵니다.)
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})        // Print it to console(토큰 값을 콘솔창에 보여줍니다. 이 토큰값으로 푸시를 전송할 대상을 정합니다.)
        print("APNs device token: \(deviceTokenString)")
        
        guard let url = URL(string: "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/token/" + deviceTokenString ) else {return }
        
        var request = URLRequest(url: url)
        
       request.httpMethod = "get"
       
       let session = URLSession.shared
       //URLSession provides the async request
       let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error took place \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print(response)
            }
        }
       // Check if Error took place
       
        task.resume()
    }
    
    // Called when APNs failed to register the device for push notifications
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }

    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }

    
//    // MARK: UISceneSession Lifecycle
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
    
    
    // Push notification received
        func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
            // Print notification payload data (푸시 데이터로 받은 것을 보여줍니다.)
            print("Push notification received: \(data)")
            
            let content = UNMutableNotificationContent()
                   
            let dict = data as! [String : Any]
            let alert = dict["aps"] as! [String : String]
           
            content.title = alert["alert"]!
            content.subtitle = ""
            content.body = ""
            content.badge = 1
            print(content.title)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(identifier: "Noti", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    

    
    func showNotification(){
        let content = UNMutableNotificationContent()
        
        content.title = "노티"
        content.body = "오늘 새로운 글이 있는지 확인해보세요!✨"
        content.badge = 1
        
        let gregorian = Calendar(identifier: .gregorian)
        let now = Date()
        var components = gregorian.dateComponents([.year,.month,.day,.hour,.minute,.second], from: now)
        
        components.hour = 21
        components.minute = 36
        let date = gregorian.date(from: components)
        let dailyTrigger = Calendar.current.dateComponents([.hour,.minute,.second], from: date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dailyTrigger, repeats: true)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "localNoti", content: content, trigger: trigger)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
