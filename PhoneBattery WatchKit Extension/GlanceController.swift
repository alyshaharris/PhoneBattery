//
//  GlanceController.swift
//  PhoneBattery WatchKit Extension
//
//  Created by Marcel Voss on 19.06.15.
//  Copyright (c) 2015 Marcel Voss. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class GlanceController: WKInterfaceController, WCSessionDelegate {
    
    var session: WCSession!

    @IBOutlet weak var percentageLabel: WKInterfaceLabel!
    @IBOutlet weak var statusLabel: WKInterfaceLabel!
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var groupItem: WKInterfaceGroup!
    
    var batteryInformationDictionary : [String: AnyObject]?
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        groupItem.setBackgroundImageNamed("frame-")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
       
        //percentageLabel.setText(String(format: "%.f%%", batteryLevel! * 100))
        //statusLabel.setText(self.stringForBatteryState(batteryState))
        titleLabel.setText(NSLocalizedString("PHONE_BATTERY", comment: ""))
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateInterface() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let batteryLevel = self.batteryInformationDictionary!["batteryLevel"] as! Int
            let batteryState = self.batteryInformationDictionary!["batteryState"] as! Int
            self.groupItem.startAnimatingWithImagesInRange(NSMakeRange(0, Int(batteryLevel)+1), duration: 1, repeatCount: 1)
            
            self.percentageLabel.setText(String(format: "%.f%%", batteryLevel))
            self.statusLabel.setText(self.batteryStateForInt(batteryState))
        }
    }
    
    func batteryStateForInt(stateInt: Int) -> String {
        if stateInt == 0 {
            return NSLocalizedString("UNKNOWN", comment: "")
        } else if stateInt == 1 {
            return NSLocalizedString("REMAINING", comment: "")
        } else if stateInt == 2 {
            return NSLocalizedString("CHARGING", comment: "")
        }  else if stateInt == 3 {
            return NSLocalizedString("FULL", comment: "")
        }
        return ""
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        batteryInformationDictionary = applicationContext
        self.updateInterface()
    }
    
}
