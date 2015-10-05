//
//  BatteryInformation.swift
//  PhoneBattery
//
//  Created by Marcel Voß on 19.09.15.
//  Copyright © 2015 Marcel Voss. All rights reserved.
//

import UIKit

class BatteryInformation: NSObject {
    
    let device = UIDevice.currentDevice()
    var batteryState : String?
    var batteryLevel : Int?
    
    override init() {
        super.init()
        
        device.batteryMonitoringEnabled = true
    }
    
    func currentBatteryLevel() -> Int {
        return Int(device.batteryLevel * 100)
    }
    
    func currentBatteryState() -> UIDeviceBatteryState {
        return device.batteryState
    }
    
    class func stringForBatteryState(batteryState: UIDeviceBatteryState) -> String {
        if batteryState == UIDeviceBatteryState.Full {
            return NSLocalizedString("FULL", comment: "")
        } else if batteryState == UIDeviceBatteryState.Charging {
            return NSLocalizedString("CHARGING", comment: "")
        } else if batteryState == UIDeviceBatteryState.Unplugged {
            return NSLocalizedString("REMAINING", comment: "")
        } else {
            return NSLocalizedString("UNKNOWN", comment: "")
        }
    }
    
}
