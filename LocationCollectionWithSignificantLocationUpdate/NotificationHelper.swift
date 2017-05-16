//
//  LocalNotificationHelper.swift
//  LocationCollectionWithSignificantLocationUpdate
//
//  Created by Krishan Sunil Premaretna on 16/5/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationHelper: NSObject {
    
    private let LOCAL_NOTIFICATION_IDENTIFIER = "LocationCollection_LocalNotification"
    private var isNotificationPermissionGranted : Bool = false
    
    static let sharedNotificationManager = NotificationHelper()
    
    required override init() {
        super.init()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {(granted, error) in
            self.isNotificationPermissionGranted = granted
        })
    }
    
    
    func addLocalNotification(_ title : String!, subtitle : String!, message : String!){
        
        if !self.isNotificationPermissionGranted {
            return
        }
        
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = message
        
        let triger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: LOCAL_NOTIFICATION_IDENTIFIER, content: content, trigger: triger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler:{ error in
            debugPrint("Notification Error : \(error?.localizedDescription)")
        })
        
    }

}
