//
//  LocationDataAccess.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 27/4/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationDataAccess: NSObject {
    
    static let applicaitonDelegate = UIApplication.shared.delegate as? AppDelegate
    
    static func insertLocationToDataBase( userLocation : CLLocation) {
        
        guard let appDelegate = applicaitonDelegate else {
            return
        }
        
        if let lastInsertedLocation = getLastInsertedUserLocation() {
        
            if (lastInsertedLocation.isEqualToCoreLocation(userLocation)) {
                
                return
            }
        
        }
        
        
        let manageOBC = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: manageOBC)
        let location = NSManagedObject(entity: entity!, insertInto: manageOBC)
        
        location.setValue( userLocation.coordinate.latitude , forKey: "latitude")
        location.setValue( userLocation.coordinate.longitude , forKey: "longitude")
        location.setValue( Int(userLocation.horizontalAccuracy), forKey: "accuracy")
        location.setValue(userLocation.timestamp, forKey: "collectedtime")
        location.setValue(CommonHelper.convertDateToString(dateToConvert: userLocation.timestamp), forKey: "collectedtimehumanreadable")
        
        do {
                try manageOBC.save()
                debugPrint("Location Inserted")
        } catch let error as NSError {
            print("Could Not Save. \(error) , \(error.localizedDescription)")
        }
    
    }
    
    
    static func getLastInsertedUserLocation() -> Location? {

        guard let appDelegate = applicaitonDelegate else {
            return nil
        }
        
        let manageOBC = appDelegate.persistentContainer.viewContext
        
        let fetchRequest : NSFetchRequest<Location> = Location.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor.init(key: "collectedtime", ascending: false) ]
        fetchRequest.fetchLimit = 1
        
        
        do {
            let result = try manageOBC.fetch(fetchRequest)
            return result.last
        } catch let error as NSError {
            print("Could Not Fetch any Object . \(error) \(error.localizedDescription)")
            
        }
        
        return nil
    }
    

}
