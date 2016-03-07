//
//  MasterViewController.swift
//  MasterDetail
//
//  Created by Jason on 2/13/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var objects = [AnyObject]()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        if let array = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [AnyObject] {
            objects = array
        }
    }

    func insertNewObject(sender: AnyObject) {
        // Add the object
        objects.insert(NSDate(), atIndex: 0)
        
        // Insert the row
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        // Save the array
        NSKeyedArchiver.archiveRootObject(objects, toFile: filePath)
    }
    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("objectsArray").path!
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row] as! NSDate
            (segue.destinationViewController as! DetailViewController).detailItem = object
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = objects[indexPath.row] as! NSDate
        cell.textLabel!.text = object.description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the object
            objects.removeAtIndex(indexPath.row)
            
            // Delete the row
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            // Save the array
            NSKeyedArchiver.archiveRootObject(objects, toFile: filePath)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

