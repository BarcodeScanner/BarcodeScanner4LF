import UIKit
import Charts
import RealmSwift

class BarChartViewController: UIViewController {
    var inventory: Inventory?
    
    @IBOutlet weak var barChartView: BarChartView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getProducts()
        barChartView.animate(yAxisDuration: 2.0)
        barChartView.pinchZoomEnabled = false
        barChartView.drawBarShadowEnabled = false
        barChartView.drawBordersEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.drawGridBackgroundEnabled = true

        // Do any additional setup after loading the view.
    }
    
    func barChartData(productName: [String], values: [Int]) {
        barChartView.noDataText = "No Data available for Chart"
        var dataEntries: [BarChartDataEntry] = []
        for i in 0..<productName.count {
        let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
        dataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Bar Chart View")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
    }
    
    func getProducts() {
        guard var inventories = inventory?.products else { return }
        let products = inventories.reduce(into: [String : Int]()) {dict, item in
            dict[item.name] = item.quantity
        }
        let xAxis = barChartView.xAxis
           xAxis.labelPosition = .bottom
           xAxis.drawAxisLineEnabled = true
           xAxis.drawGridLinesEnabled = false
           xAxis.granularityEnabled = false
           xAxis.labelRotationAngle = -25
       //    xAxis.setLabelCount(rawData.count, force: false)
           xAxis.valueFormatter = IndexAxisValueFormatter(values: products.map { $0.key })
         //  xAxis.axisMaximum = Double(rawData.count)
         //  xAxis.axisLineColor = .chartLineColour
         //  xAxis.labelTextColor = .chartLineColour

        barChartData(productName: Array(products.keys), values: Array(products.values))
    }

}
