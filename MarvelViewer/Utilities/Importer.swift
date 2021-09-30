import Foundation
import CoreData

/// Imports data from the REST API into Core Data
class Importer {
  static let shared = Importer()
  
  private init() { }
  
  /**
   Add your API key.
   
   See https://developer.marvel.com/documentation/authorization for more on `ts` and `hash`.
   
   Parameters:
    - apiKey: Marvel API key
    - ts: ts value, must be same as used to generate hash
    - hash: MD5 hash of `md5(ts+privateKey+publicKey)`
   */
  func setApiAuthentication(apiKey: String, ts: String, hash: String) {
    self.apiKey = apiKey
    self.ts = ts
    self.hash = hash
  }
  
  /// API Key used for Marvel API access. Reads from the Info.plist file - MarvelKeys.apikey
  var apiKey: String?
  
  /// `ts` value used for Marvel API access. Reads from the Info.plist file - MarvelKeys.ts
  var ts: String?
  
  /// Hash used for Marvel API access. Reads from the Info.plist file - MarvelKeys.hash
  var hash: String?
  
  /// Queries the Marvel API, loads results into Core Data. Uses a cache, so requests that have suceeded in the past may work offline. Uses `load(...)` and `toCoreData(...)` internally.
  public func fetchFromAPI(limit: Int, offset: Int, nameStartsWith: String? = nil, done: ((Bool) -> Void)? = nil ) {
    let context = DataStore.shared.backgroundContext
    context.perform {
      self.fetchFromServer(context: context, limit: limit, offset: offset, nameStartsWith: nameStartsWith, done: done)
    }
  }
  
  private func fetchFromServer(context: NSManagedObjectContext, limit: Int, offset: Int, nameStartsWith: String?, done: ((Bool) -> Void)? ) {
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    
    
    guard let apiKey = apiKey, let ts = ts, let hash = hash else {
      print("No marvel api key, hash, and/or ts value. Please add these to the info.plist file.")
      done?(false)
      return
    }
    
    var urlString = "https://gateway.marvel.com/v1/public/characters?apikey=\(apiKey)&ts=\(ts)&hash=\(hash)&limit=\(limit)&offset=\(offset)"
    
    if let nameStartsWith = nameStartsWith {
      urlString.append(contentsOf: "&nameStartsWith=\(nameStartsWith)")
    }
    
    let URL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
    
    var request = URLRequest(url: URL)
    request.httpMethod = "GET"
    request.cachePolicy = .returnCacheDataElseLoad
    
    let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
      context.perform {
        if (error == nil) {
          let response: Marvel.API.Characters.DataWrapper = self.load(data: data!)
          
          if let data = response.data, let results = data.results {
            self.toCoreData(results, nameStartsWith: nameStartsWith, context: context)
          }
          done?(true)
          
        } else {
          // Failure
          DispatchQueue.main.async {
            print("URL Session Task Failed: %@", error!.localizedDescription)
            done?(false)
          }
        }
      }
    })
    task.resume()
    session.finishTasksAndInvalidate()
  }
  
  /// Translates JSON from the API into Decodable objects
  func load(data: Data) -> Marvel.API.Characters.DataWrapper {
    var result: Marvel.API.Characters.DataWrapper
    let decoder = JSONDecoder()
    
    do {
      result = try decoder.decode(Marvel.API.Characters.DataWrapper.self, from: data)
    } catch (let error) {
      var status: [String] = [error.localizedDescription]
      
      let nserror = error as NSError
      status.append(nserror.debugDescription)
      
      result = Marvel.API.Characters.DataWrapper(code: 900, status: status.joined(separator: "\n"), data: nil)
    }
    
    return result
  }
  
  /// Updates Core Data to include the passed Decodable objects
  func toCoreData(_ characters: [Marvel.API.Characters.Character], nameStartsWith: String?, context: NSManagedObjectContext) {
    let search = Search.findOrCreate(searchText: nameStartsWith ?? "", context: context)
    
    for item in characters {
      let c = Character.findOrCreate(id: item.id, context: context)
      
      // update core data record properties only if it's new, or has a newer server side modified timestamp than the local copy
      if (c.modified ?? .distantPast) < (item.modifiedAsDate ?? .distantFuture) {
        c.name = item.name
        c.modified = item.modifiedAsDate
        
        let marvelDescription = item.description
        if marvelDescription != "" {
          c.marvelDescription = marvelDescription
        }
        
        c.thumbnailUrl = [item.thumbnail.path, ".", item.thumbnail.extension].joined()
        
        if let detailsUrl = item.urls.filter({$0.type == "details"}).first {
          c.readMoreLink = detailsUrl.url
        } else {
          c.readMoreLink = item.urls.first?.url
        }
        
        for series in item.series.items {
          let s = Series.findOrCreate(resourceURI: series.resourceURI, context: context)
          s.name = series.name
          c.addToSeries(s)
        }
      }
      
      c.addToSearches(search)
    }
    
    DataStore.shared.save(context: context)
  }
}
