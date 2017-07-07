//
//  PlayList+CoreDataClass.swift
//  BookPlay
//
//  Created by Jarco Katsalay on 6/16/17.
//  Copyright © 2017 Jarco Katsalay. All rights reserved.
//

import Foundation
import CoreData

@objc(PlayList)
public class PlayList: NSManagedObject {
    func getAll() -> [MediaItem] {
        
        let fetchRequest = NSFetchRequest<MediaItem>(entityName: "MediaItem")
        
        fetchRequest.predicate = NSPredicate(format: "playlist == %@", self)
        
        do {
            
            let mediaItems = try self.managedObjectContext?.fetch(fetchRequest) ?? []
            
            return mediaItems
        } catch {
            fatalError("Error while fetching all media items from playlist: \(error)")
        }
    }
}
