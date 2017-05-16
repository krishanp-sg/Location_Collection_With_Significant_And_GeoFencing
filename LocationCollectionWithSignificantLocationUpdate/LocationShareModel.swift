//
//  LocationShareModel.swift
//  Location_Collection
//
//  Created by Krishan Sunil Premaretna on 11/5/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit

class LocationShareModel: NSObject {
    
    static let sharedInstance = LocationShareModel()
    
    var backgroundTimer : Timer?
    var stopLocationManagerAfter10sTimer : Timer?
    var bagTaskManager : BackgroundTaskManager?
    
    
   required override init(){
    
    }

}
