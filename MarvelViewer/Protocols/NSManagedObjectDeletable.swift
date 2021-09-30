import Foundation
import CoreData

protocol NSManagedObjectDeletable {
  static func destroyAll(context: NSManagedObjectContext)
}

extension NSManagedObjectDeletable {
  static func destroyAll(context: NSManagedObjectContext = DataStore.shared.backgroundContext){
    context.perform {
      let request = (self as! NSManagedObject.Type).fetchRequest()
      request.entity = (self as! NSManagedObject.Type).entity()
      
      var objects:[Any]
      do {
        objects = try context.fetch(request)
      } catch {
        objects = []
      }
      for obj in objects {
        context.delete(obj as! NSManagedObject)
      }
      
      DataStore.shared.save(context: context)
    }
  }
}
