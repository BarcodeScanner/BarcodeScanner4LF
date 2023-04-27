//
//  CSVExporter.swift
//  BarcodeScanner
//
//  Created by Crina Ciobotaru on 26.04.2023.
//

import Foundation
import CSV

class CSVExporter {
    static let rootName = "/InventoryApp/"
    lazy var appDocumentDirectory: URL = {
        do {
            let folderURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: false
            )
            return folderURL
        } catch {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
    }()
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    func export(inventory: Inventory) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH_mm_ss_YY_MMM_d"
        let fileName = "\(dateFormatter.string(from: Date())).csv"
        let docURL = appDocumentDirectory
        let dataPath = docURL.appendingPathComponent(CSVExporter.rootName)
        let root = documentsPath.appending(CSVExporter.rootName)
        if !FileManager.default.fileExists(atPath: root) {
            do {
                try FileManager.default.createDirectory(atPath: root, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        let path = root.appending(fileName)
        let stream = OutputStream(toFileAtPath: path, append: false)!
        let csv = try! CSVWriter(stream: stream)
        
        let names = Array(inventory.products.compactMap { $0.name })
        let quantities = Array(inventory.products.compactMap { String($0.quantity) })
        let barcodes = Array(inventory.products.compactMap { $0.barcode })
        let prices = Array(inventory.products.compactMap { $0.price })
        let totalvalues = Array(inventory.products.compactMap { "\(Int($0.intPrice) * $0.quantity)" })
        // Write header first
        let header = ["Name", "Barcode", "Quantity", "Price", "Total Value"]
        try! csv.write(row: header)
        for index in 0..<names.count {
            try! csv.write(row: [names[index], barcodes[index], quantities[index], prices[index], totalvalues[index]])
        }
            
        csv.stream.close()
    }
    
}
