import UIKit
import Charts
import RealmSwift

class BarChartViewController: UIViewController, ChartViewDelegate {
    var inventory: Inventory?
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var priceChartView: BarChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProducts()
        chartSetUp()
        
        self.getPriceProducts()
        priceChartSetUp()
        
        let newinventoryImage = UIImage(systemName: "plus")
        let newInventoryButton = UIBarButtonItem(image: newinventoryImage, style: .plain, target: self, action: #selector(exportToCSV))
        navigationItem.rightBarButtonItem = newInventoryButton
    }
    
    @objc func exportToCSV() {
        guard let inventory = self.inventory else { return }
        let csvExporter = CSVExporter()
        csvExporter.export(inventory: inventory)
    }
    
    func barChartData(productName: [String], values: [Int]) {
        barChartView.noDataText = "No Data available for Chart"
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<productName.count {
        let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
        dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Product's quantity")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }
    
    
    func getProducts() {
        guard let inventories = inventory?.products else { return }
        let products = inventories.reduce(into: [String : Int]()) {dict, item in
            dict[item.name] = item.quantity
           
        }
        let xAxis = priceChartView.xAxis
        xAxis.setLabelCount(products.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: products.map { $0.key })
        
        barChartData(productName: Array(products.keys), values: Array(products.values))
    }
    
    func chartSetUp() {
        barChartView.delegate = self
        barChartView.animate(yAxisDuration: 1.5)
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = false
        
        barChartView.highlightPerTapEnabled = true
        barChartView.highlightFullBarEnabled = true
        barChartView.highlightPerDragEnabled = false
        
        let xAxis = barChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.labelRotationAngle = -25
        
        let leftAxis = barChartView.leftAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        
        leftAxis.setLabelCount(6, force: true)
        leftAxis.axisMinimum = 0.0
        
        // Remove right axis
        let rightAxis = barChartView.rightAxis
        rightAxis.enabled = false
    }
    
    func priceChartData(productName: [String], values: [Double]) {
        priceChartView.noDataText = "No Data available for Chart"
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<productName.count {
        let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
        dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Product's price")
        let chartData = BarChartData(dataSet: chartDataSet)
        priceChartView.data = chartData
    }
    
    
    func getPriceProducts() {
        guard let inventories = inventory?.products else { return }
        let products = inventories.reduce(into: [String : Double]()) {dict, item in
            dict[item.name] = item.intPrice
        }
        let xAxis = barChartView.xAxis
        xAxis.setLabelCount(products.count, force: false)
        xAxis.valueFormatter = IndexAxisValueFormatter(values: products.map { $0.key })
        
        priceChartData(productName: Array(products.keys), values: Array(products.values))
    }
    
    func priceChartSetUp() {
        priceChartView.delegate = self
        priceChartView.animate(yAxisDuration: 1.5)
        priceChartView.pinchZoomEnabled = false
        priceChartView.drawBarShadowEnabled = false
        priceChartView.drawBordersEnabled = false
        priceChartView.doubleTapToZoomEnabled = false
        priceChartView.drawGridBackgroundEnabled = false
        
        priceChartView.highlightPerTapEnabled = true
        priceChartView.highlightFullBarEnabled = true
        priceChartView.highlightPerDragEnabled = false
        
        let xAxis = priceChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = false
        xAxis.granularityEnabled = false
        xAxis.labelRotationAngle = -25
        
        let leftAxis = priceChartView.leftAxis
        leftAxis.drawTopYLabelEntryEnabled = true
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = false
        
        leftAxis.setLabelCount(6, force: true)
        leftAxis.axisMinimum = 0.0
        
        // Remove right axis
        let rightAxis = priceChartView.rightAxis
        rightAxis.enabled = false
    }
    
   

}
