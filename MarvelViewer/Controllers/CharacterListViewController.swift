import UIKit
import CoreData

/// Shows a searchable list of Marvel characters
class CharacterListViewController: UITableViewController, UISearchBarDelegate, NSFetchedResultsControllerDelegate, InfiniteScrollingDelegate {
  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    listFooter = ListFooter.fromNib()
    listFooter?.delegate = self
    
    searchBar?.delegate = self
    tableView.register(UINib(nibName: "CharacterTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "CharacterTableViewCell")
    tableView.delegate = self
    
    self.setUpDataSource()
    
    // kick off search for blank list
    if (fetchedResultsController?.fetchedObjects?.count ?? 0) == 0 {
      requestFirstPage()
    }
    
    let deleteAndRefreshAction = UIAction(title: "Delete all and reload 1st page", attributes: UIMenuElement.Attributes.destructive, state: UIMenuElement.State.off, handler: { _ in 
      Character.destroyAll()
      Search.destroyAll()
      Series.destroyAll()
      self.requestFirstPage()
    })
    
    let deleteAction = UIAction(title: "Delete all data", state: UIMenuElement.State.off, handler: { _ in 
      Character.destroyAll()
      Search.destroyAll()
      Series.destroyAll()
      URLCache.shared.removeAllCachedResponses()
    })
    
    let clearCache = UIAction(title: "Clear cache", state: UIMenuElement.State.off, handler: { _ in 
      URLCache.shared.removeAllCachedResponses()
    })
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .trash, primaryAction: nil, menu: UIMenu(title: "Developer Tools", image: nil, identifier: nil, options: .displayInline, children: [deleteAndRefreshAction, deleteAction, clearCache]))
    
  }
  
  // MARK: - Searching + UISearchBarDelegate
  @IBOutlet var searchBar: UISearchBar?
  var searchText: String?
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    self.searchBar(searchBar, textDidChange: "")
    searchBar.resignFirstResponder()
    searchBar.showsCancelButton = false
  }
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.showsCancelButton = true
    return true
  }
  
  /// When the search text changes, search for that text via the cache and/or REST API
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchText = (searchText == "") ? nil : searchText
    setUpDataSource()
    self.isFetching = false
    listFooter?.hideSpinner()
    listFooter?.hideLoadMoreButton()
    requestFirstPage()
  }
  
  // MARK: - Diffable Data Source
  /// UITableViewDiffableDataSource for the table view
  var dataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID>?
  
  /// Holds the data shown by the table view
  var fetchedResultsController:NSFetchedResultsController<Character>?
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    let newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
    
    guard let dataSource = tableView?.dataSource as? UITableViewDiffableDataSource<Int, NSManagedObjectID> else {
      assertionFailure("The data source has not implemented snapshot support while it should")
      return
    }
    var snapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
    let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>
    
    // the NSManagedObject objectID is used as a key. this objectID does not change if properties of the object change. so check for this here, and reload any changed items
    let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
      guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
        return nil
      }
      guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
      return itemIdentifier
    }
    snapshot.reloadItems(reloadIdentifiers)
    
    // now apply the new snapshot
    dataSource.apply(newSnapshot, animatingDifferences: false)
  }
  private func setUpDataSource() {
    let source = DataSource(nameStartsWith: searchText ?? "", tableView: tableView, delegate: self)
    dataSource = source.dataSource
    fetchedResultsController = source.fetchedResultsController
    source.performFetch()
  }
  
 // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    searchBar?.resignFirstResponder()
    
    if let character = fetchedResultsController?.object(at: indexPath) {
      let details = DetailViewController(character: character)
      navigationController?.pushViewController(details, animated: true)
    }
  }
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let numberItems = fetchedResultsController?.fetchedObjects?.count else { return }
    let onRow = indexPath.row
    
    // TODO: - make this more efficient. by storing the total count (returned and not returned) in the Search model, and only calling requestNextPage() if the total count available > what's already been loaded. 
    if numberItems - onRow <= 20 {
      requestNextPage()
    }
  }
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return listFooter
  }
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    44.0
  }
  
  // MARK: - Pagination
  /// Shows a loading indicator (when loading), empty when loaded, "Load more" button when error or no internet.
  var listFooter: ListFooter?
  // MARK: - InfiniteScrollingDelegate
  var pageSize = 30
  var isFetching = false
  var onPage: Int {
    get {
      guard let numberItems = fetchedResultsController?.fetchedObjects?.count else { return 0 }
      
      return numberItems / pageSize
    }
  }
  func requestNextPage() {
    requestNextChunk(offset: onPage * pageSize)
  }
  func requestFirstPage() {
    requestNextChunk(offset: 0)
  }
  private func requestNextChunk(offset: Int) {
    if isFetching {
      return
    }
    
    listFooter?.showSpinner()
    listFooter?.hideLoadMoreButton()
    isFetching = true
    Importer.shared.fetchFromAPI(limit: pageSize, offset: offset, nameStartsWith: searchText, done: { [weak self] (success: Bool) in
      DispatchQueue.main.async { [weak self] in
        self?.listFooter?.hideSpinner()
        if success {
          self?.listFooter?.hideLoadMoreButton()
        } else {
          self?.listFooter?.showLoadMoreButton()
        }
        self?.isFetching = false
      }
    })
  }
}

