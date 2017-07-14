//
//  CoreDataHelper.swift
//  PilotHandy
//
//  Created by Jerry Walton on 6/26/16.
//  Copyright © 2016 Symbolic Languages LLC. All rights reserved.
//

import Foundation
import CoreData

typealias CompletionHandlerArray = (NSArray!, NSError!) -> Void

class CoreDataHelper {
    
    class func createObjectWithEntityName(entityName: String, coreDataStack: CoreDataStack) -> NSManagedObject? {
        
        return NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: coreDataStack.managedObjectContext!)
    }
    
    class func deleteObject(object: NSManagedObject, coreDataStack: CoreDataStack) {
        coreDataStack.managedObjectContext!.deleteObject(object)
        coreDataStack .saveContext()
    }
    
    class func fetchObjectWithEntityName(entityName: String, predicate: NSPredicate!, coreDataStack: CoreDataStack) -> NSManagedObject? {

        let fetchRequest = NSFetchRequest(entityName: entityName)
        if (predicate != nil) {
            fetchRequest.predicate = predicate
        }
        
        do {
            let fetchResults = try coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest)
            return fetchResults[0] as? NSManagedObject
        } catch let fetchError as NSError {
            print("fetchError: \(fetchError)")
            return nil
        }

    }
    
    class func fetchObjectsWithEntityName(entityName: String, predicate: NSPredicate!, coreDataStack: CoreDataStack) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if (predicate != nil) {
            fetchRequest.predicate = predicate
        }
        
        do {
            let fetchResults = try coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest)
            return fetchResults as? [NSManagedObject]
        } catch let fetchError as NSError {
            print("fetchError: \(fetchError)")
            return nil
        }
        
    }
    
    class func fetchObjectsWithEntityName(entityName: String, predicate: NSPredicate!, sortDescriptors: [NSSortDescriptor]?, coreDataStack: CoreDataStack) -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest(entityName: entityName)
        if (predicate != nil) {
            fetchRequest.predicate = predicate
        }
        
        if (sortDescriptors != nil) {
            fetchRequest.sortDescriptors = sortDescriptors
        }
        
        do {
            let fetchResults = try coreDataStack.managedObjectContext!.executeFetchRequest(fetchRequest)
            return fetchResults as? [NSManagedObject]
        } catch let fetchError as NSError {
            print("fetchError: \(fetchError)")
            return nil
        }
        
    }
    
    class func performFetch(name: String, predicate: NSPredicate?, sortDescriptors: NSArray?, managedObjectContext: NSManagedObjectContext, completionHandler:CompletionHandlerArray) {
        
        let fetchRequest = NSFetchRequest(entityName: name)
        
        do {
            let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest)
            completionHandler(fetchResults, nil)
        } catch let fetchError as NSError {
            completionHandler(nil, fetchError)
        }
        
    }
    
    class func fetchObjects(name: String, predicate: NSPredicate?, sortDescriptors: NSArray?, managedObjectContext: NSManagedObjectContext) -> NSArray? {
        
        let fetchRequest = NSFetchRequest(entityName: name)
        
        // uwrap to check for nil
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        // uwrap to check for nil
        if let sortDescriptors = sortDescriptors {
            fetchRequest.sortDescriptors = sortDescriptors as? [NSSortDescriptor]
        }
        
        var array : NSArray!
        
        do {
            if let fetchResults: NSArray! = try managedObjectContext.executeFetchRequest(fetchRequest) {
                array = NSArray(array: fetchResults)
            }
        } catch let fetchError as NSError {
            fetchError
        }
        
        return array
    }
    
    class func fetchObject(name: String, predicate: NSPredicate?, managedObjectContext: NSManagedObjectContext) -> NSManagedObject? {
        
        let fetchRequest = NSFetchRequest(entityName: name)
        
        if let predicate = predicate {
            fetchRequest.predicate = predicate
        }
        
        var mo : NSManagedObject!
        
        do {
            if let fetchResults: NSArray! = try managedObjectContext.executeFetchRequest(fetchRequest) {
                if fetchResults.count > 0 {
                    mo = fetchResults[0] as! NSManagedObject
                }
            }
        } catch let fetchError as NSError {
            fetchError
        }
        
        return mo
    }
    
}