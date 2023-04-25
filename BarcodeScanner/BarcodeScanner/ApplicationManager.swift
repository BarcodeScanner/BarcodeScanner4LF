import Foundation
import RealmSwift

class ApplicationManager {
    static var shared = ApplicationManager()
    var realmConfiguration: Realm.Configuration?
    var user: User?
    var realm: Realm?
    @ObservedResults(Product.self) var products
    
    private init() {
        app.syncManager.errorHandler = { syncError, session in
            if let thisError = syncError as? SyncError {
                switch thisError.code {
                    
                case .clientSessionError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .clientUserError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .clientInternalError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .clientResetError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .underlyingAuthError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .permissionDeniedError:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .invalidFlexibleSyncSubscriptions:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                case .writeRejected:
                    if let errorInfo = thisError.compensatingWriteInfo {
                        for anError in errorInfo {
                            print(anError.reason as Any)
                        }
                    }
                @unknown default:
                    break
                }
            }
        }
    }
    
    func openFlexibleSyncRealm(for user: User) async throws -> Realm {
        var config = user.flexibleSyncConfiguration()
        config.objectTypes = [Product.self, Inventory.self]
        let realm = try await Realm(configuration: config)
        print("Successfully opened realm: \(realm)")
        let subscriptions = realm.subscriptions
        try await subscriptions.update {
            if subscriptions.first(named: Constants.allProducts) == nil {
                subscriptions.append(QuerySubscription<Product>(name: Constants.allProducts))
            }
            if subscriptions.first(named: Constants.allInventories) == nil {
                subscriptions.append(QuerySubscription<Inventory>(name: Constants.allInventories))
            }
        }
        return realm
    }
}
