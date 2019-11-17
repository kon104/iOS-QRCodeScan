//
//  ViewController.swift
//  QRCodeScan
//
//  Created by kon104 on 2019/11/10.
//  Copyright © 2019 kon104. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var lblType: UILabel!
    @IBOutlet var txtValue: UITextView!
    @IBOutlet var btnAction: UIButton!
    @IBOutlet weak var tblDetactions: UITableView!

    var aryTypes: [AVMetadataObject.ObjectType] = []
    var aryValues: [String] = []
    var curIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btnAction.layer.borderColor = UIColor.blue.cgColor
        btnAction.layer.borderWidth = 1.0
        btnAction.layer.cornerRadius = 20.0
    }
    
    @IBAction func btnActionTapped(_ sender: Any) {
        var value = txtValue.text
        if self.aryTypes[self.curIndex] == AVMetadataObject.ObjectType.ean13 {
            value = "https://www.amazon.co.jp/s?k=" + value!
        }
        if let url = URL(string: value!) {
            // web to
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("[Start]" + #function)
        print("[End]" + #function)
        return self.aryValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("[Start]" + #function)
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SampleCell")
        cell.textLabel?.text = self.aryValues[indexPath.row]
        print("[End]" + #function)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.activeTableRow(indexPath.row)
    }
    
    func activeTableRow(_ rownum: Int) {
        self.curIndex = rownum
        self.lblType.text = self.aryTypes[rownum].rawValue
        self.txtValue.text = self.aryValues[rownum]
    }
}

