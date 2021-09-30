import Foundation
import CoreData

/// A search for a character. Linked to all characters (`searchText = ""`), or characters starting with `searchText`.
/// 
/// Open `MarvelViewer.xcdatamodeld` for properties. Swift doc can't load generated Core Data model files.
class Search: NSManagedObject, NSManagedObjectDeletable {
  
  static func findOrCreate(searchText: String?, context: NSManagedObjectContext) -> Search {
    
    let request = fetchRequest()
    request.predicate = NSPredicate(format: "searchText = %@")
    request.entity = self.entity()
    
    var obj: Search?
    let objects: [Search]? = try? context.fetch(request)
    
    if objects?.count == 1 {
      obj = objects!.first
    }
    
    if obj == nil {
      obj = Search.init(context: context)
      obj?.searchText = searchText
    }
    
    return obj!
  }
}
