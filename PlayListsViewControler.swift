//
//  MasterViewController.swift
//  BookPlay
//
//  Created by Jarco Katsalay on 6/16/17.
//  Copyright © 2017 Jarco Katsalay. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import AVKit
import AVFoundation

class PlayListsViewControler: UITableViewController, NSFetchedResultsControllerDelegate, MPMediaPickerControllerDelegate, PlayListsTableViewCellDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var delegate: PlayListsViewControlerDelegate? = nil
    
    var playerVC: PlayerViewController {
        return delegate as! PlayerViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(chooseSongsButtonPressed(_:)))
        navigationItem.rightBarButtonItem = addButton
 
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func chooseSongsButtonPressed(_ sender: UIButton) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.allowsPickingMultipleItems = true
        myMediaPickerVC.popoverPresentationController?.sourceView = sender
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! MediaItemsViewController
                controller.playList = object
                controller.managedObjectContext = self.managedObjectContext
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let playList = fetchedResultsController.object(at: indexPath)
        configureCell(cell as! PlayListsTableViewCell, withPlayList: playList)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [unowned self] action, index in
            let context = self.fetchedResultsController.managedObjectContext
            context.delete(self.fetchedResultsController.object(at: indexPath))
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        let rename = UITableViewRowAction(style: .normal, title: "Rename") { action, index in
            print("Rename button tapped")
        }
        rename.backgroundColor = .lightGray
        
        return [rename, delete]
    }

    func configureCell(_ cell: PlayListsTableViewCell, withPlayList playList: PlayList) {
        cell.nameLabel.text = playList.name ?? ""
        cell.playList = playList
        cell.playing = (playerVC.currentPlayList == playList && playerVC.playing)
        cell.delegate = self
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<PlayList> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<PlayList> = PlayList.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "PlayLists")
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
    var _fetchedResultsController: NSFetchedResultsController<PlayList>? = nil

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
                configureCell(tableView.cellForRow(at: indexPath!)! as! PlayListsTableViewCell, withPlayList: anObject as! PlayList)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)! as! PlayListsTableViewCell, withPlayList: anObject as! PlayList)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    // MARK: - MPMediaPickerControllerDelegate
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        let context = self.fetchedResultsController.managedObjectContext
        let newPlayList: PlayList!
        if mediaItemCollection.items.count > 0 {
            newPlayList = PlayList(context: context)
            newPlayList.timestamp = NSDate()
            newPlayList.name = mediaItemCollection.items.first?.albumTitle ?? ""
            
            for item in mediaItemCollection.items {
                let newMediaItem = MediaItem(context: context)
                newMediaItem.name = item.title
                newMediaItem.url = item.assetURL?.absoluteString
                newMediaItem.persistentID = Int64(item.persistentID)
                newMediaItem.playlist = newPlayList
            }
            
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PlayListsTableViewCellDelegate
    func play(_ playList: PlayList) {
        delegate?.play(playList)
    }
    
    func pause(_ playList: PlayList) {
        delegate?.pause(playList)
    }

}

protocol PlayListsViewControlerDelegate {
    func play(_ playList: PlayList)
    func pause(_ playList: PlayList)
}

