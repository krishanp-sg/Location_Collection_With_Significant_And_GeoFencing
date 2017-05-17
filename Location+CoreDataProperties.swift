//
//  Location+CoreDataProperties.swift
//  LocationCollectionWithSignificantLocationUpdate
//
//  Created by Krishan Sunil Premaretna on 15/5/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location");
    }

    @NSManaged public var accuracy: Int16
    @NSManaged public var collectedtime: NSDate?
    @NSManaged public var collectedtimehumanreadable: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

    
    func isEqualToCoreLocation(_ location : CLLocation) -> Bool{
        var isEqual : Bool = false
        let timeInterval : Double =   location.timestamp.timeIntervalSince(self.collectedtime as! Date) //(self.collectedtime!.timeIntervalSince(location.timestamp))
        
        if timeInterval < 0 {
            return true
        }
        
        
        if(location.distance(from: CLLocation(latitude: latitude, longitude: longitude)) < 100 &&  timeInterval < 300.0) {
            isEqual = true
        }
        
        
        return isEqual
    }
}
