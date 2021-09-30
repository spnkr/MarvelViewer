import XCTest
import UIKit
import CoreData
@testable import MarvelViewer

class MarvelViewerTests: XCTestCase {
  
  override func setUpWithError() throws {
    Character.destroyAll()
    Search.destroyAll()
    Series.destroyAll()
  }
  
  override func tearDownWithError() throws {
    Character.destroyAll()
    Search.destroyAll()
    Series.destroyAll()
    sleep(5) // bc we use the same db file for tests and the app, give it time to clear
             // proper way is to use a separate core data .sqlite file for tests
  }
  
  private func mock(for name: MockData) -> Data {
    let path = Bundle(for: MarvelViewerTests.self).path(forResource: name.rawValue, ofType: "json")!
    return try! Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
  }
  
  /// Test 
  func testJSONToCoreDataLoading() throws {
    let moc = DataStore.shared.context
    
    let e = XCTestExpectation()
    let data = mock(for: .charactersPage1)
    
    moc.perform {
      let results = Importer.shared.load(data: data)
      
      XCTAssertNotNil(results.data?.results)
      
      if let chars = results.data?.results {
        Importer.shared.toCoreData(chars, nameStartsWith: nil, context: moc)
      }
      
      // TODO: - add more assertions for id, name, thumbnail url, etc.
      XCTAssertEqual(Character.countAll(), 100)
      
      let predicate = NSPredicate(format: "id = %@ and name = %@ and thumbnailUrl = %@ and marvelDescription = %@",
                                  argumentArray: [
                                    1009696,
                                    "Viper",
                                    "http://i.annihil.us/u/prod/marvel/i/mg/b/40/image_not_available.jpg",
                                    "After the apparent death of Baron von Strucker, Viper took the name Madame Hydra and took control of the New York-based faction of Hydra."
                                  ])
      
      XCTAssertEqual(Character.countFor(predicate), 1)
      
      e.fulfill()
    }
    
    wait(for: [e], timeout: 10.0)
  }
  
  
  /// Remove all data. Search for "Su", then go back to list of all characters. Characters starting with "Su" should not appear in the list until you scroll down to the S-es.
  func testOfflineSearchResultsIsolation() throws {
    let moc = DataStore.shared.context
    
    let e = XCTestExpectation()
    let searchByName = mock(for: .searchByName)
    let charactersPage1 = mock(for: .charactersPage1)
    
    
    moc.perform {
      
      let resultsName = Importer.shared.load(data: searchByName)
      let resultsCharacters = Importer.shared.load(data: charactersPage1)
      
      XCTAssertNotNil(resultsName.data?.results)
      
      if let chars = resultsName.data?.results {
        Importer.shared.toCoreData(chars, nameStartsWith: "su", context: moc)
      }
      
      XCTAssertEqual(Character.countAll(), 16)
      
      if let chars = resultsCharacters.data?.results {
        Importer.shared.toCoreData(chars, nameStartsWith: nil, context: moc)
      }
      
      XCTAssertEqual(Character.countAll(), 116)
      
      let s = DataSource(nameStartsWith: "su", tableView: UITableView(), delegate: TableViewControllerMock())
      s.performFetch()
      
      XCTAssertEqual(s.fetchedResultsController!.fetchedObjects!.count, 16)
      
      e.fulfill()
    }
    
    wait(for: [e], timeout: 10.0)
  }
}
