import Foundation
import CoreData

/// Core Data stack
class DataStore {
  static let shared = DataStore()
  
  private init() { }
  
  /// Read-only context for use on main thread.
  lazy var context: NSManagedObjectContext = {
    persistentContainer.viewContext
  }()
  
  /// Single background context for all writes, and background data loading.
  public lazy var backgroundContext: NSManagedObjectContext = {
    let newbackgroundContext = persistentContainer.newBackgroundContext()
    newbackgroundContext.automaticallyMergesChangesFromParent = true
    newbackgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    return newbackgroundContext
  }()
  
  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "MarvelViewer")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    container.viewContext.automaticallyMergesChangesFromParent = true
    
    return container
  }()
  
  /// Saves the `NSManagedObjectContext` to disk.
  func save(context: NSManagedObjectContext = DataStore.shared.context) {
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // log error here. handle if out of disk space, etc.
      }
    }
  }
}
