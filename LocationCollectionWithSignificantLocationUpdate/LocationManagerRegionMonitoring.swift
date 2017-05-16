//
//  LocationManagerRegionMonitoring.swift
//  LocationCollectionWithSignificantLocationUpdate
//
//  Created by Krishan Sunil Premaretna on 15/5/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManagerRegionMonitoring: NSObject {
    
    private let distanceFilter  = 50.0
    private static let REGION_IDENTIFIER = "IDLERegion"
    private static let REGION_RADIUS = 20.0
    
    static let sharedManager = LocationManagerRegionMonitoring()
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var locationShareModel = LocationShareModel()
    fileprivate var isAppInBackground : Bool = false
    fileprivate var userLastLocation : CLLocation?
    fileprivate var regionToMonitor : CLRegion?
    
    required override init() {
        super.init()
        
        let notificationCenter = NotificationCenter.default
        
        // App will Enter Background
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        // App Will Enter Foreground
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
    }
    
    // Setup Normal LocationManager
    func setupLocationManager(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.distanceFilter = distanceFilter
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.requestAlwaysAuthorization()
        
        stopMonitoringRegions()
        
        self.locationManager.startUpdatingLocation()
        
    }
    
    // Stop Location Manager
    func stopLocationManager(){
        
        CommonHelper.writeToFile("Location Manager Stopped ")
        self.locationManager.stopUpdatingLocation()
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
    
    //App Moved To Background
    func appMovedToBackground(){
        CommonHelper.writeToFile("App Moved To Background ")
        self.isAppInBackground = true
        self.locationManager.stopUpdatingLocation()
        self.locationManager.startUpdatingLocation()
        
        self.locationShareModel.bagTaskManager = BackgroundTaskManager.shared()
        self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()
        
    }
    
    //App Moved To Foreground
    func appMovedToForeground(){
        debugPrint("App Moved To Foreground")
        
        self.isAppInBackground = false
        stopBackgroundTimers()
        stopLocationManager()
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func appWillTerminate(){
        CommonHelper.writeToFile("App Will Terminate ")
        setupRegionMonitoring()
        
    }
    
    
    // Stop Timer
    func stopBackgroundTimers(){
        
        if self.locationShareModel.backgroundTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
        
        if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
            self.locationShareModel.backgroundTimer?.invalidate()
            self.locationShareModel.backgroundTimer = nil
        }
    }
    
    func setupRegionMonitoring(){
      
        
        stopLocationManager()
        stopBackgroundTimers()

        isAppInBackground = true
        
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            if let userLastLocation = userLastLocation {
            
                regionToMonitor = CLCircularRegion(center: userLastLocation.coordinate, radius: LocationManagerRegionMonitoring.REGION_RADIUS, identifier: LocationManagerRegionMonitoring.REGION_IDENTIFIER)
                regionToMonitor!.notifyOnExit = true
                regionToMonitor!.notifyOnEntry = true
                self.locationManager.startMonitoring(for: regionToMonitor!)
                CommonHelper.writeToFile("Setup Region Monitoring Called success ")
            }
            

        }

    }
    
    func stopMonitoringRegions(){
        
        for region in self.locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == LocationManagerRegionMonitoring.REGION_IDENTIFIER else { continue }
            self.locationManager.stopMonitoring(for: circularRegion)
            CommonHelper.writeToFile("Stop Monitoring regions ")
        }
    }
    
    func startTimers(){
       
        if locationShareModel.backgroundTimer != nil{
            return
        }
        
        self.locationShareModel.bagTaskManager = BackgroundTaskManager.shared()
        self.locationShareModel.bagTaskManager?.beginNewBackgroundTask()
        
        self.locationShareModel.backgroundTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(restartLocationUpdate), userInfo: nil, repeats: false)
        
        
        if self.locationShareModel.stopLocationManagerAfter10sTimer != nil {
            self.locationShareModel.stopLocationManagerAfter10sTimer?.invalidate()
            self.locationShareModel.stopLocationManagerAfter10sTimer = nil
        }
        
        
        self.locationShareModel.stopLocationManagerAfter10sTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(stopLocationManager), userInfo: nil, repeats: false)
    }

}

extension LocationManagerRegionMonitoring : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        debugPrint("Location Manager Error : \(error.localizedDescription)")
        
        if isAppInBackground {
            startTimers()
        } else {
            self.locationManager.stopUpdatingLocation()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        userLastLocation = locations.last!
        
        debugPrint("Did Update Location Called")
        
        // If the user is IDLE for 5 minutes turn off the location and Start Significant location update.
        if let lastUserLocation = LocationDataAccess.getLastInsertedUserLocation(), isAppInBackground {
            
            let lastLocation : CLLocation = CLLocation(latitude: lastUserLocation.latitude, longitude: lastUserLocation.longitude)
            
            // if Distance Between location is less than 100m and time difference is greater than 5 minute turn off GPS
            
            if locations.last!.distance(from: lastLocation) < 100 && locations.last!.timestamp.timeIntervalSince(lastUserLocation.collectedtime as! Date) > 300 {
                
                setupRegionMonitoring()
                
                return
            }
            
        }
        
        
        LocationDataAccess.insertLocationToDataBase(userLocation: locations.last!)
        
        if isAppInBackground {
            
            startTimers()
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       
        CommonHelper.writeToFile("User Entered In to The region ")
        self.locationManager.stopMonitoring(for: region)
        self.setupLocationManager()
        self.appMovedToBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("User Left The Region")
        // TODO : User have exits the idle position. Stop monitoring region and remove the existing regions. and start location update.
        
    
        CommonHelper.writeToFile("User Left The region ")
        self.locationManager.stopMonitoring(for: region)
        self.setupLocationManager()
        debugPrint("didExitRegion")
        self.appMovedToBackground()
        
    }

    
    
}
