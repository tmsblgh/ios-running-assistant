//
//  RunTableViewController.swift
//  Running Assistant
//
//  Created by Balogh Tamás on 2018. 04. 12..
//  Copyright © 2018. Balogh Tamás. All rights reserved.
//

import UIKit
import CoreData

class RunTableViewController: UIViewController {
    
    private let segueRunDetailsViewController = "SegueRunDetailsViewController"
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    private let persistentContainer = NSPersistentContainer(name: "Running_Assistant")
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Run> = {
        let fetchRequest: NSFetchRequest<Run> = Run.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } else {
                self.setupView()
                
                do {
                    try self.fetchedResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                self.updateView()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? RunDetailsViewController else { return }
        
        destinationViewController.managedObjectContext = persistentContainer.viewContext
        
        if let indexPath = tableView.indexPathForSelectedRow, segue.identifier == segueRunDetailsViewController {
            destinationViewController.run = fetchedResultsController.object(at: indexPath)
        }
    }
    
    private func setupView() {
        setupMessageLabel()
        
        updateView()
    }
    
    private func updateView() {
        var hasRuns = false
        
        if let runs = fetchedResultsController.fetchedObjects {
            hasRuns = runs.count > 0
        }
        
        tableView.isHidden = !hasRuns
        messageLabel.isHidden = hasRuns
        
        activityIndicatorView.stopAnimating()
    }
    
    private func setupMessageLabel() {
        messageLabel.text = "Még nincs mentett futásod."
    }
    
}

extension RunTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? RunTableViewCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            break;
        }
    }
}

extension RunTableViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let runs = fetchedResultsController.fetchedObjects else { return 0 }
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RunTableViewCell.reuseIdentifier, for: indexPath) as? RunTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func configure(_ cell: RunTableViewCell, at indexPath: IndexPath) {
        let run = fetchedResultsController.object(at: indexPath)
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "yyyy/MM/dd"
        
        cell.dateLabel.text = dateformatter.string(from: run.date!)
        cell.distanceLabel.text = String(format:"Megtett távolság: %.1f km", run.distance/1000)
        cell.averageSpeedLabel.text = String(format:"Átlagsebesség: %.1f km/h", run.averageSpeed)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let run = fetchedResultsController.object(at: indexPath)
            
            run.managedObjectContext?.delete(run)
        }
    }
    
}

extension RunTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

