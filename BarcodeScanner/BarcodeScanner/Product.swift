import Foundation
import RealmSwift

class Product: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var barcode: String = ""
    @Persisted var price: String = ""
    @Persisted var quantity: Int = 0
    @Persisted var owner_id: String
    
    var intPrice: Double {
        return Double(price) ?? 0.0
    }
    
    convenience init(name: String, barcode: String, price: String, quantity: Int) {
        self.init()
        self.name = name
        self.barcode = barcode
        self.price = price
        self.quantity = quantity
        self.owner_id = ApplicationManager.shared.user?.id ?? ""
    }
}
