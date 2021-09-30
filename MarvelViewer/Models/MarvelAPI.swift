import Foundation

enum Marvel {
  enum API {
    enum Characters {
      struct DataWrapper: Decodable {
        public var code: Int
        public var status: String
        public var data: Marvel.API.Characters.DataContainer?
      }
      
      struct DataContainer: Decodable {
        public var offset: Int
        public var limit: Int
        public var total: Int
        public var count: Int
        public var results: [Marvel.API.Characters.Character]?
      }
      
      struct Character: Decodable {
        public var id: Int
        public var name: String
        public var description: String
        public var thumbnail: Marvel.API.Image
        public var modified: String
        
        /// Up to 20 of the series this character can be found in
        public var series: Marvel.API.Series.SeriesList
        
        /// URLs on marvel.com for this character
        public var urls: [Marvel.API.Url]
        
        /// Converts `modified` into a `Date`
        public var modifiedAsDate: Date? {
          get {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter.date(from: modified)
          }
        }
      }
    }
    
    struct Image: Decodable {
      public var path: String
      public var `extension`: String
    }
    
    struct Url: Decodable {
      public var type: String
      public var url: String
    }
    
    enum Series {
      struct SeriesList: Decodable {
        public var available: Int
        public var returned: Int
        public var collectionURI: String
        public var items: [Marvel.API.Series.SeriesSummary]
      }
      struct SeriesSummary: Decodable {
        public var resourceURI: String
        public var name: String
      }
    }
  }
}
