//
//  InventoriesViewController.swift
//  BarcodeScanner
//
//  Created by Crina Ciobotaru on 20.04.2023.
//

import UIKit

class InventoriesViewController: UIViewController {

    @IBOutlet weak var inventoriesTableView: UITableView!
    @IBOutlet weak var showMyTaskSwitch: UISwitch!
    @IBAction func didTouchLogOut(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func didTouchAddNewInventory(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func didTouchWorkOffline(_ sender: UIBarButtonItem) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
