//
//  ViewController.swift
//  LocationCollectionWithSignificantLocationUpdate
//
//  Created by Krishan Sunil Premaretna on 15/5/17.
//  Copyright © 2017 Krishan Sunil Premaretna. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var locationCountLabel: UILabel!
    @IBOutlet weak var locationTableView: UITableView!
    
    fileprivate var locaitons = [Location]()
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest : NSFetchRequest<Location> = Location.fetchRequest()
        fetchRequest.sortDescriptors = [ NSSortDescriptor.init(key: "collectedtime", ascending: false) ]
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let manageOBC = appDelegate?.persistentContainer.viewContext
        
        let fetchedResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: manageOBC!, sectionNameKeyPath: nil, cacheName: nil)
        
        
        fetchedResultsController.delegate = self
        
        
        return fetchedResultsController as! NSFetchedResultsController<NSFetchRequestResult>
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.locationTableView.register(UINib(nibName: "LocationCellTableViewCell", bundle: nil), forCellReuseIdentifier: LocationCellTableViewCell.identifier)
        self.locationTableView.rowHeight = UITableViewAutomaticDimension
        self.locationTableView.estimatedRowHeight = 117
        
        
        do {
            try self.fetchedResultsController.performFetch()
            
        } catch let error as NSError {
            print("Unable to perform fetch request \(error), \(error.localizedDescription)")
        }

    }

    func setupRightNavigationBarLabel(_ locationCount : Int){
        self.locationCountLabel.text = "Location Count : \(locationCount)"
        locationCountLabel.sizeToFit()
    }
}


extension ViewController : UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let locations = fetchedResultsController.fetchedObjects else {
            return 0
        }
        setupRightNavigationBarLabel(locations.count)
        return locations.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard  let cell = tableView.dequeueReusableCell(withIdentifier: LocationCellTableViewCell.identifier, for: indexPath) as? LocationCellTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let location = self.fetchedResultsController.object(at: indexPath)
        //Configure Cell
        cell.configureCell(location: location as! Location)
        
        return cell
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.locationTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.locationTableView.endUpdates()
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                self.locationTableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        default:
            print("...")
        }
    }
    
    
}


