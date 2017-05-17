//
//  LocationManager.swift
//  LocationCollectionWithSignificantLocationUpdate
//
//  Created by Krishan Sunil Premaretna on 15/5/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject {
    
    private let distanceFilter  = 50.0
    
    static let sharedManager = LocationManager()
    
    fileprivate var locationManager : CLLocationManager = CLLocationManager()
    fileprivate var locationShareModel = LocationShareModel()
    fileprivate var isAppInBackground : Bool = false
    fileprivate var isSignificantLocationUpdate : Bool = false
    
    
    required override init() {
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        // App will Enter Background
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // App Will Enter Foreground
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        self.locationShareModel.bagTaskManager = BackgroundTaskManager.shared()
        self.locationShareModel.bagTaskManager?.delegate = self
        
    }
    
    // Setup Normal LocationManager
    func setupLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.distanceFilter = distanceFilter
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        stopSignificantLocationUpdate()
        self.locationManager.startUpdatingLocation()
    
    }
    
    // Stop Location Manager
    func stopLocationManager(){
        
//        if !isSignificantLocationUpdate {
            CommonHelper.writeToFile("Stopping Location Manager ")
            self.locationManager.stopUpdatingLocation()
//        }

    }
    
    // restart Location Manager
    func restartLocationUpdate(){
 
         CommonHelper.writeToFile("Location Manager Restarted ")
       
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
            self.locationManager.startUpdatingLocation()
    }
    
    // Setup Significant LocationManager
    func setupSignificantLocationUpdate(){
        stopBackgroundTimers()
        stopLocationManager()
        self.isSignificantLocationUpdate = true
        
        CommonHelper.writeToFile("Location Manager Stopping because Signifacnt Monitor going to Start ")
        self.locationManager.startMonitoringSignificantLocationChanges()
        CommonHelper.writeToFile("Significant Location Update Started ")
    }
    
    // Stop SignificantLocationManager
    func stopSignificantLocationUpdate(){
        CommonHelper.writeToFile("Significant Location Update Stopped ")
        self.locationManager.stopMonitoringSignificantLocationChanges()
        self.isSignificantLocationUpdate = false
    }
    
    
    //App Moved To Background
    func appMovedToBackground(){
        CommonHelper.writeToFile("App Moved To Background ")
        self.isAppInBackground = true
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()

       
        self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()

    }
    
    //App Moved To Foreground
    func appMovedToForeground(){
        CommonHelper.writeToFile("App Moved To Foreground ")
        
        self.isAppInBackground = false
        stopBackgroundTimers()
        stopLocationManager()
        stopSignificantLocationUpdate()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    //App Will Terminate
    func appWillTerminate(){
        CommonHelper.writeToFile("App Will Terminate ")
        setupSignificantLocationUpdate()
    }
    
    
    // Stop Timer
    func stopBackgroundTimers(){
       
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
            self.locationShareModel.stopLocationManagerAfter10sTimer?.invalidate()
            self.locationShareModel.stopLocationManagerAfter10sTimer = nil
        }

    }
    
    func startTimers(){
        
        if locationShareModel.backgroundTimer != nil{
            return
        }
        
        
        self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()
        
        self.locationShareModel.backgroundTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(restartLocationUpdate), userInfo: nil, repeats: false)
        
        
        if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
            self.locationShareModel.stopLocationManagerAfter10sTimer?.invalidate()
            self.locationShareModel.stopLocationManagerAfter10sTimer = nil
        }
        
        
        self.locationShareModel.stopLocationManagerAfter10sTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(stopLocationManager), userInfo: nil, repeats: false)
    }
    

}



extension LocationManager : CLLocationManagerDelegate, BackgroundMansterTaskExpireDelagte {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
         CommonHelper.writeToFile("Location Manager Did Fail with Error \(error.localizedDescription) ")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        debugPrint("Did Update Location Called")
        
        // If the user is IDLE for 5 minutes turn off the location and Start Significant location update.
        if let lastUserLocation = LocationDataAccess.getLastInsertedUserLocation(), isAppInBackground, !isSignificantLocationUpdate{
            
            let lastLocation : CLLocation = CLLocation(latitude: lastUserLocation.latitude, longitude: lastUserLocation.longitude)
            
            // if Distance Between location is less than 100m and time difference is greater than 5 minute turn off GPS
            
            if locations.last!.distance(from: lastLocation) < 100 && locations.last!.timestamp.timeIntervalSince(lastUserLocation.collectedtime as! Date) > 300 && !isSignificantLocationUpdate {
                
                CommonHelper.writeToFile("Setting Up Significant location update because user is idle ")
                setupSignificantLocationUpdate()
                
                return
            }
            
        }

        LocationDataAccess.insertLocationToDataBase(userLocation: locations.last!)
        
        if isSignificantLocationUpdate {

            
            self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()

            stopSignificantLocationUpdate()
            setupLocationManager()
            CommonHelper.writeToFile("Setting Up Location Manager because location update received From Significant Location Update ")
        }
        
        if isAppInBackground {
            print("Application is in Background")
            startTimers()
        }
    }
    
    
    func masterTaskExpired() {
        CommonHelper.writeToFile("Setting Up Significant Location Update, because master task expired ")
        
        if isSignificantLocationUpdate {
            CommonHelper.writeToFile("Significant Location Update alredy started , no need to start again. ")
            return
        }
        setupSignificantLocationUpdate()
    }


}
