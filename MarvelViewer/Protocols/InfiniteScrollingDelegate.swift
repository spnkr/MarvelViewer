import Foundation

protocol InfiniteScrollingDelegate {
  /// Fetch and load the next page of data
  func requestNextPage()
  
  /// Current page
  var onPage: Int { get }
  
  /// Page size of API requests
  var pageSize: Int { get }
  
  /// Is a request to the API currently running?
  var isFetching: Bool { get set }
}
