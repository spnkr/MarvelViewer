import UIKit

/// Large character image table view cell
class BigImageTableViewCell: UITableViewCell {
  
  @IBOutlet var bigImageView: UIImageView!
  
  /// URL string of the image for this cell
  var imageUrl: String? = nil
  
  /// Image download task
  var dataTask: URLSessionDataTask? = nil
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  /// Configuring cell from model
  func configureCell(character: Character) {
    selectionStyle = .none
    
    bigImageView.image = nil
    imageUrl = character.thumbnailUrl!
    
    let url = URL(string:imageUrl!)!
    var urlRequest = URLRequest(url: url)
    urlRequest.cachePolicy = .returnCacheDataElseLoad
    
    let cached = URLCache.shared.cachedResponse(for: urlRequest)
    if let data = cached?.data {
      bigImageView?.image = UIImage(data: data)
    } else {
      fetchRemoteImage(url: url, urlRequest: urlRequest)
    } 
  }
  
  /// Loads the image at this URL from the cache, or from the network. Caches based on the URL, including parameters.
  func fetchRemoteImage(url: URL, urlRequest: URLRequest) {
    let dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
      if error != nil {
        // do not do anything if there is an error
        // e.g. -999 -> data task was cancelled
        // e.g. invalid URL, can't load from network - it just ignores and tries again next time you scroll past
      } else {
        if let data = data {
          
          // Save response, if valid, in the URLCache
          if let response = response,
             URLCache.shared.cachedResponse(for: urlRequest) == nil,
             let data = try? Data(contentsOf: url) {
            
            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: urlRequest)
          }
          
          // Update cell
          DispatchQueue.main.async { [weak self] in
            if urlRequest.url?.absoluteString == self?.imageUrl {
              self?.bigImageView?.image = UIImage(data: data)
            }
          }
          
        }
      }
      
    }
    
    dataTask.resume()
    self.dataTask = dataTask
  }
  
  // MARK: - Memory management
  override func prepareForReuse() {
    super.prepareForReuse()
    // cancel any pending downloads before the cell gets re-used
    dataTask?.cancel()
  }
  
  deinit {
    // cancel any pending downloads before the cell object gets removed from memory
    dataTask?.cancel()
  }
  
}

