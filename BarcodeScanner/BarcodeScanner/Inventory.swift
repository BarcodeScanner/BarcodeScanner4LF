import Foundation
import RealmSwift

class Inventory: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var owner_id: String
    @Persisted var products: List<Product>
    
    convenience init(name: String) {
        self.init()
        self.name = name
        self.owner_id = ApplicationManager.shared.user?.id ?? ""
    }
}
