//
//  ConfigViewController.swift
//  tableviewSwift
//
//  Created by Philip Gross on 2/16/20.
//  Copyright © 2020 Philip Gross. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {

    @IBOutlet weak var ipAddressField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!

    
    var pickerData: [String] = [String]()
    var mainVc: ViewController?
    
    var events: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        self.ipAddressField.delegate = self
        
        //read in saved ip addresses
        let defaults = UserDefaults.standard
        pickerData = defaults.stringArray(forKey: "pickerData") ?? [String]()
        if pickerData == [] {
            pickerData.append("10.0.0.251")
        }
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        ipAddress = pickerData[selectedValue]
        
    }
    
    @IBAction func removePressed(_ sender: Any) {
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        print("selected", selectedValue)
        pickerData.remove(at: selectedValue)
        self.pickerView.reloadAllComponents()
        savePickerData()
    }
    
    @IBAction func refreshedPressed(_ sender: Any) {
        let selectedValue = pickerView.selectedRow(inComponent: 0)
        print("selected", selectedValue)
        ipAddress = pickerData[selectedValue]
        mainVc?.loadAll(ipAddr: ipAddress)
    }
    
    @IBAction func addPressed(_ sender: Any) {
        print("add pressed")
        if ipAddressField.endEditing(false) {
            print("ending editting, button pressed")
            ipAddress = ipAddressField.text ?? "10.0.0.251"
            if !pickerData.contains(ipAddress) {
                print("add it")
                pickerData.append(ipAddress)
                pickerData.sort()
                self.pickerView.reloadAllComponents()
            }
            savePickerData()
            mainVc?.loadAll(ipAddr: ipAddress)
        }
        else {
            print("button pressed")
        }
        //doXmlRead()
    }

    func savePickerData() {
        //save ip addresses
        let defaults = UserDefaults.standard
        defaults.set(pickerData, forKey: "pickerData")
    }
}

extension ConfigViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        print(pickerData[row], row, component)
        ipAddress = pickerData[row]
        //doXmlRead()
    }
}

extension ConfigViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("done editing")
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("began editing")
    }
}
