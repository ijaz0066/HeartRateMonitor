//
//  ViewController.swift
//  HeartRateMonitor
//
//  Created by ijaz ahmad on 2019-06-27.
//  Copyright © 2019 BodiTrak. All rights reserved.
//

import UIKit
import CoreBluetooth

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")


class HeartRateViewController: UIViewController {
    
    
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var sensorLocationLabel: UILabel!
    
    
    var centralManager: CBCentralManager!
    var heartRatePeripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func onHeartRateReceived(_ heartRate: Int) {
        heartRateLabel.text = String(heartRate)
    }
}
//CBCentralManagerDelegate methods
extension HeartRateViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            Common.showErrorMessage(view: self.view, errorMessage: "State is unknown")
        case .resetting:
            Common.showErrorMessage(view: self.view, errorMessage: "State is resetting")
        case .unsupported:
            Common.showErrorMessage(view: self.view, errorMessage: "State is unsupported")
        case .unauthorized:
            Common.showErrorMessage(view: self.view, errorMessage: "State is unauthorized")
        case .poweredOff:
            Common.showErrorMessage(view: self.view, errorMessage: "Your Bluetooth is poweredOff!")
        case .poweredOn:
            Common.showSuccessMessage(view: self.view, successMessage: "Bluetooth is poweredOn!")
            centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID], options: nil)
        default:
            print("Unhandeled state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        heartRatePeripheral = peripheral
        heartRatePeripheral.delegate = self
        centralManager.stopScan()
        centralManager.connect(heartRatePeripheral, options: nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("connected!")
        Common.showSuccessMessage(view: self.view, successMessage: "Connected!")
         heartRatePeripheral.discoverServices([heartRateServiceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Common.showErrorMessage(view: self.view, errorMessage: "Failed to connect please try again!")
    }
}
// CBPeripheralDelegate methods
extension HeartRateViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            let bodySensorLocation = bodyLocation(from: characteristic)
            sensorLocationLabel.text = bodySensorLocation
        case heartRateMeasurementCharacteristicCBUUID:
            let heartRate = calculateHeartRate(from: characteristic)
            onHeartRateReceived(heartRate)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
}
//Helper methods
extension HeartRateViewController {
    //to measure body location
    private func bodyLocation(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value,
            let byte = characteristicData.first else { return "Error" }
        
        switch byte {
        case 0: return "Other"
        case 1: return "Chest"
        case 2: return "Wrist"
        case 3: return "Finger"
        case 4: return "Hand"
        case 5: return "Ear Lobe"
        case 6: return "Foot"
        default:
            return "Reserved for future use"
        }
    }
    //To calculate heart rate
    private func calculateHeartRate(from characteristic: CBCharacteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        
        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // Heart Rate Value Format is in the 2nd byte
            return Int(byteArray[1])
        } else {
            // Heart Rate Value Format is in the 2nd and 3rd bytes
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
    
}

