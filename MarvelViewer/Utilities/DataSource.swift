import Foundation
import CoreData
import UIKit

/// Source for UITableView. Handles DiffableDataSource + NSFetchedResultsController implementation.
class DataSource {
  var dataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID>?
  var fetchedResultsController: NSFetchedResultsController<Character>?
  var search: Search?
  
  init(nameStartsWith: String?, tableView: UITableView, delegate: NSFetchedResultsControllerDelegate) {
    let moc = DataStore.shared.context
    
    dataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { (tableView, indexPath, item) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterTableViewCell", for: indexPath) as! CharacterTableViewCell
      
      let character = moc.object(with: item) as! Character
      cell.configureCell(character: character)
      
      return cell
    })
  
    // bind to search query with search terms, so main list isn't polluted with old cached searches
    let request = Character.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
    
    search = Search.findOrCreate(searchText: nameStartsWith ?? "", context: moc)
    DataStore.shared.save(context: moc)
    
    request.predicate = NSPredicate(format: "(ANY searches.searchText == %@)", argumentArray: [nameStartsWith ?? ""])
    
    self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
    
    self.fetchedResultsController?.delegate = delegate
  }
  
  func performFetch() {
    try! self.fetchedResultsController?.performFetch()
  }
}
