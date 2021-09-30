import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    //Ask me for an api key, ts value, and hash you can use:
    //Importer.shared.setApiAuthentication(apiKey: "key", ts: "ts", hash: "hash")
    assert(Importer.shared.apiKey != nil && Importer.shared.ts != nil && Importer.shared.hash != nil)
    
    let cache = URLCache(memoryCapacity: 4 * 1024 * 1024, diskCapacity: 150 * 1024 * 1024, diskPath: nil)
    URLCache.shared = cache
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .systemBackground
    
    // not using UISceneSession because it doesn't work with hot code reloading.
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let root = storyboard.instantiateInitialViewController()
    
    window?.rootViewController = root
    window?.makeKeyAndVisible()
    
    return true
  }

}
