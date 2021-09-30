import UIKit

/// Combination progress spinner and 'retry' button. Used on list view screen.
class ListFooter: UIView {
  @IBOutlet var spinner: UIActivityIndicatorView!
  @IBOutlet var loadMoreButton: UIButton!
  var delegate: InfiniteScrollingDelegate?
  
  /// Tells the delegate to try to load the next page of results
  @IBAction func loadMore() {
    delegate?.requestNextPage()
  }
  func showSpinner() {
    spinner.isHidden = false
    spinner.startAnimating()
  }
  func hideSpinner() {
    spinner.isHidden = true
    spinner.stopAnimating()
  }
  func showLoadMoreButton() {
    loadMoreButton.isHidden = false
  }
  func hideLoadMoreButton() {
    loadMoreButton.isHidden = true
  }
  
  class func fromNib<ListFooter>() -> ListFooter {
    return Bundle.main.loadNibNamed("ListFooter", owner: nil, options: nil)![0] as! ListFooter
  }
}

