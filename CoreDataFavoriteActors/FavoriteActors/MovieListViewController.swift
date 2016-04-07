//
//  MovieListViewController.swift
//  FavoriteActors
//
//  Created by Jason on 1/31/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import CoreData

/**
* Challenge Step 2: Convert Movie List to Fetched Results View Controller.
*/

// Step 5: The view controller should conform to the NSFetchedResultsController protocol
class MovieListViewController : UITableViewController, NSFetchedResultsControllerDelegate {
    
    // This array needs to be replaced by a lazy fetchedResultsController property
    var actor: Person!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Step 2: Perform the fetch
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        
        // Step 6: Set the delegate to this view controller
        fetchedResultsController.delegate = self

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if actor.movies.isEmpty {
            
            let resource = TheMovieDB.Resources.PersonIDMovieCredits
            let parameters = [TheMovieDB.Keys.ID : actor.id]
            
            TheMovieDB.sharedInstance().taskForResource(resource, parameters: parameters){ JSONResult, error  in
                if let error = error {
                    print(error)
                } else {
                    
                    if let moviesDictionaries = JSONResult.valueForKey("cast") as? [[String : AnyObject]] {
                        
                        // Parse the array of movies dictionaries
                        let _ = moviesDictionaries.map() { (dictionary: [String : AnyObject]) -> Movie in
                            let movie = Movie(dictionary: dictionary, context: self.sharedContext)
                            
                            movie.actor = self.actor
                            
                            return movie
                        }
                        
                        // Update the table on the main thread
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.reloadData()
                        }
                        
                        // Save the context
                        self.saveContext()
                        
                    } else {
                        let error = NSError(domain: "Movie for Person Parsing. Cant find cast in \(JSONResult)", code: 0, userInfo: nil)
                        print(error)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Core Data Convenience
    
    lazy var sharedContext: NSManagedObjectContext =  {
        return CoreDataStackManager.sharedInstance().managedObjectContext
        }()
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    
    // Mark: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Movie")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "actor == %@", self.actor);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()

    
    
    // MARK: - Table View
    
    // Step 3: Update these three table view methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return actor.movies.count
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movie = fetchedResultsController.objectAtIndexPath(indexPath) as! Movie
        let CellIdentifier = "MovieCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! TaskCancelingTableViewCell
        
        // This is the new configureCell method
        configureCell(cell, movie: movie)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (editingStyle) {
        case .Delete:
            //actor.movies.removeAtIndex(indexPath.row)
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            let movie = fetchedResultsController.objectAtIndexPath(indexPath) as! Movie
            sharedContext.deleteObject(movie)
            CoreDataStackManager.sharedInstance().saveContext()
            
            
        default:
            break
        }
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    // Step 4: This would be a great place to add the delegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! ActorTableViewCell
            let movie = controller.objectAtIndexPath(indexPath!) as! Movie
            self.configureCell(cell, movie: movie)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        default:
            return
        }
    }
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }

    
    // MARK: - Configure Cell
    
    func configureCell(cell: TaskCancelingTableViewCell, movie: Movie) {
        var posterImage = UIImage(named: "posterPlaceHoldr")
        
        cell.textLabel!.text = movie.title
        cell.imageView!.image = nil
        
        // Set the Movie Poster Image
        
        if movie.posterPath == nil || movie.posterPath == "" {
            posterImage = UIImage(named: "noImage")
        } else if movie.posterImage != nil {
            posterImage = movie.posterImage
        }
            
        else { // This is the interesting case. The movie has an image name, but it is not downloaded yet.
            
            // This first line returns a string representing the second to the smallest size that TheMovieDB serves up
            let size = TheMovieDB.sharedInstance().config.posterSizes[1]
            
            // Start the task that will eventually download the image
            let task = TheMovieDB.sharedInstance().taskForImageWithSize(size, filePath: movie.posterPath!) { data, error in
                
                if let error = error {
                    print("Poster download error: \(error.localizedDescription)")
                }
                
                if let data = data {
                    // Craete the image
                    let image = UIImage(data: data)
                    
                    // update the model, so that the infrmation gets cashed
                    movie.posterImage = image
                    
                    // update the cell later, on the main thread
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = image
                    }
                }
            }
            
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            cell.taskToCancelifCellIsReused = task
        }
        
        cell.imageView!.image = posterImage
    }
}
