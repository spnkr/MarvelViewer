import Foundation
import CoreData

/// A series that has a character in it.
/// 
/// Open `MarvelViewer.xcdatamodeld` for properties. Swift doc can't load generated Core Data model files.
class Series: NSManagedObject, NSManagedObjectDeletable {
  
  static func findOrCreate(resourceURI: String?, context: NSManagedObjectContext) -> Series {
    
    let request = fetchRequest()
    request.predicate = NSPredicate(format: "resourceURI = %@")
    request.entity = self.entity()
    
    var obj: Series?
    let objects: [Series]? = try? context.fetch(request)
    
    if objects?.count == 1 {
      obj = objects!.first
    }
    
    if obj == nil {
      obj = Series.init(context: context)
      obj?.resourceURI = resourceURI
    }
    
    return obj!
  }
  
}
