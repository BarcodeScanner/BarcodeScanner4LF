import Foundation
import RealmSwift

struct Constants {
    static let allItems = "all_items"
    static let myItems = "my_items"
}

struct AppConfig {
    var appId: String
    var baseUrl: String
}

func loadAppConfig() -> AppConfig {
    guard let path = Bundle.main.path(forResource: "atlas", ofType: "plist") else {
        fatalError("Could not load info.plist file!")
    }

    let data = NSData(contentsOfFile: path)! as Data
    let atlasConfigPropertyList = try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
    let appId = atlasConfigPropertyList["appId"]! as! String
    let baseUrl = atlasConfigPropertyList["baseUrl"]! as! String
    return AppConfig(appId: appId, baseUrl: baseUrl)
}
