//
//  DetailViewController.swift
//  MovieReview
//
//  Created by Sean on 4/9/18.
//  Copyright © 2018 Sean. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var managedObjectContext: NSManagedObjectContext! = nil


    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)
        let review = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withReview: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func configureCell(_ cell: UITableViewCell, withReview review: Review) {
        cell.textLabel!.text = String(review.rating)
        cell.detailTextLabel!.text = review.opinion
    }
    
    
    func configureView() {
        // Update the user interface for the detail item.
        if let movie = movie {
            self.title = "\(movie.name!) (\(movie.year))"
        }
    }
    // MARK: - Fetched results controller
    
    var fetchedResultsController: NSFetchedResultsController<Review> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Review> = Review.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Filter for respective movie.
        let predicate = NSPredicate(format: "movie == %@", movie!)
        fetchRequest.predicate = predicate
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Review>? = nil
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withReview: anObject as! Review)
        case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withReview: anObject as! Review)
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        
        // If appropriate, configure the new managed object.
        //   newMovie.timestamp = Date()
        //   newMovie.name = "e"
        //   newMovie.year = 1984
        let alert = UIAlertController(title: "Add Review", message: "E", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "A"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "rating (1 to 5)"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        let add = UIAlertAction(title: "Add", style: .default) { (_) in
            let context = self.fetchedResultsController.managedObjectContext
            let newReview = Review(context: context)
            newReview.opinion = alert.textFields![0].text!
            newReview.rating =  Int16(alert.textFields![1].text!)!
            newReview.timestamp = Date()
            newReview.movie = self.movie
            // save the context
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        alert.addAction(add)
        present(alert, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var movie: Movie? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

