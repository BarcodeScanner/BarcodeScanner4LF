import Foundation
import RealmSwift

class Product: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var barcode: String = ""
    @Persisted var quantity: Int = 0
    @Persisted var owner_id: String
    
    convenience init(name: String, barcode: String, quantity: Int) {
        self.init()
        self.name = name
        self.barcode = barcode
        self.quantity = quantity
        self.owner_id = ApplicationManager.shared.user?.id ?? ""
    }
}
