import Foundation
import RealmSwift

class Product: Object {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String = ""
    @Persisted var barcode: String = ""
    @Persisted var quantity: Int = 0
    
    convenience init(name: String, barcode: String, quantity: Int) {
        self.init()
        self.name = name
        self.barcode = barcode
        self.quantity = quantity
    }
}
