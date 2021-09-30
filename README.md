#  Readme

### ⚠️ API Key

Put your Marvel API key, `ts` value, and `hash` value in `application(_:didFinishLaunchingWithOptions:)` before running:

```swift
Importer.shared.setApiAuthentication(apiKey: "api key", ts: "1", hash: "foo")
```

### Requirements
- Xcode 13
- iOS 15

### Features
- Stores searches and characters in core data
- Main character list uses a predicate linking to a blank search
- Offline works for previous searches, and for the main list
- Characters loaded in a text search don't show up in the main list until you've paginated down to where they appear alphabetically
- Uses URLCache to stay under the marvel api limits (3000 requests/day), and to keep images in memory/on-disk
- Two unit tests
- Trash icon on list screen lets you clear Core Data and/or the URLCache
- Dynamic type and dark mode support

### Future Improvements
- Add an expiry date to URLCached requests so new characters show up after initial load
- More unit tests
- Use cloudinary to dynamically re-size thumbnail images to be smaller
- Store total result count in the Search object
- Performance improvement: add debounce, or a queue to requesting the next page from the server
- Load full series list from API when the detail view controller is opened
- Store date fetched for saved searches, and use the `modifiedSince` query parameter to update them
- Visual indicator that you're in offline mode (via Reachability)
- Optimize layout for iPad using a split view controller
