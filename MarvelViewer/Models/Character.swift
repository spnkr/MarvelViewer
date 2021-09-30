import Foundation
import CoreData

/// A Marvel character
/// 
/// Open `MarvelViewer.xcdatamodeld` for properties. Swift doc can't load generated Core Data model files.
class Character: NSManagedObject, NSManagedObjectDeletable {
  
  static func countAll() -> Int{
    countFor(NSPredicate(format: "1 = 1"), context: DataStore.shared.context)
  }
  static func countFor(_ predicate: NSPredicate?) -> Int{
    countFor(predicate, context: DataStore.shared.context)
  }
  static func countFor(_ predicate: NSPredicate?, context:NSManagedObjectContext) -> Int{
    let request = fetchRequest()
    request.predicate = predicate
    request.entity = self.entity()
    
    var count:Int = 0
    do {
      count = try context.count(for: request)
    } catch {
      // log error with level .debug here
    }
    
    return count
  }
  static func findOrCreate(id: Int, context: NSManagedObjectContext) -> Character {
    
    let request = fetchRequest()
    request.predicate = NSPredicate(format: "id = %@")
    request.entity = self.entity()
    
    var obj: Character?
    let objects: [Character]? = try? context.fetch(request)
    
    if objects?.count == 1 {
      obj = objects!.first
    }
    
    if obj == nil {
      obj = Character.init(context: context)
      obj?.id = Int32(id)
    }
    
    return obj!
  }
}

