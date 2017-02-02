//
//  SettingsVC.swift
//  MBSageGrabber
//
//  Created by Kent Hall on 10/17/16.
//  Copyright © 2016 kentahallis. All rights reserved.
//

import Foundation
import UserNotifications

class SettingsVC: UIViewController{
    var defaults:UserDefaults = UserDefaults(suiteName: "group.grabberData")!
    @IBOutlet weak var lunchNotifLabel: UILabel!
    @IBOutlet weak var dinnerNotifLabel: UILabel!
    @IBOutlet weak var lunchNotifSwitch: UISwitch!
    @IBAction func lunchNotifSwitch(_ sender: UISwitch) {
        switch sender.isOn{
        case true:
            defaults.set(true, forKey: "LunchNotifOn")
            if (NSCalendar.current.component(Calendar.Component.hour, from: Date()) < defaults.integer(forKey: "LunchNotifHour") || (NSCalendar.current.component(Calendar.Component.hour, from: Date()) == defaults.integer(forKey: "LunchNotifHour") && NSCalendar.current.component(Calendar.Component.minute, from: Date()) < defaults.integer(forKey: "LunchNotifMin"))) {
                if #available(iOS 10.0, *) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lunchRequest"])
                    UniversalMethods.addUNNotif(hour: defaults.integer(forKey: "LunchNotifHour"), minute: defaults.integer(forKey: "LunchNotifMin"), text: self.defaults.string(forKey: "Lunch")!.components(separatedBy: "<")[0], title: "Lunch Today", id: "lunch", noMealString: FetchData().noMealString)
                }
            }
        case false:
            defaults.set(false, forKey: "LunchNotifOn")
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lunchRequest"])
            }
        }
    }
    @IBOutlet weak var dinnerNotifSwitch: UISwitch!
    @IBAction func dinnerNotifSwitch(_ sender: UISwitch) {
        switch sender.isOn{
        case true:
            defaults.set(true, forKey: "DinnerNotifOn")
            if (NSCalendar.current.component(Calendar.Component.hour, from: Date()) < defaults.integer(forKey: "DinnerNotifHour") || (NSCalendar.current.component(Calendar.Component.hour, from: Date()) == defaults.integer(forKey: "DinnerNotifHour") && NSCalendar.current.component(Calendar.Component.minute, from: Date()) < defaults.integer(forKey: "DinnerNotifMin"))) {
                if #available(iOS 10.0, *) {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dinnerRequest"])
                    UniversalMethods.addUNNotif(hour: defaults.integer(forKey: "DinnerNotifHour"), minute: defaults.integer(forKey: "DinnerNotifMin"), text: self.defaults.string(forKey: "Dinner")!.components(separatedBy: "<")[0], title: "Dinner Today", id: "dinner", noMealString: FetchData().noMealString)
                }
            }
        case false:
            defaults.set(false, forKey: "DinnerNotifOn")
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dinnerRequest"])
            }
        }
    }
    @IBOutlet weak var lunchNotifTimePicker: UIDatePicker!
    @IBAction func lunchNotifTimePicker(_ sender: UIDatePicker) {
        defaults.set(NSCalendar.current.component(Calendar.Component.hour, from: sender.date), forKey: "LunchNotifHour")
        defaults.set(NSCalendar.current.component(Calendar.Component.minute, from: sender.date), forKey: "LunchNotifMin")
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lunchRequest"])
            if (!UniversalMethods.lunchNotifPassed(defaults: self.defaults)) {
                UniversalMethods.addUNNotif(hour: defaults.integer(forKey: "LunchNotifHour"), minute: defaults.integer(forKey: "LunchNotifMin"), text: defaults.string(forKey: "Lunch")!.components(separatedBy: "<")[0], title: "Lunch Today", id: "lunch", noMealString: FetchData().noMealString)
            }
        }
    }
    @IBOutlet weak var dinnerNotifTimePicker: UIDatePicker!
    @IBAction func dinnerNotifTimePicker(_ sender: UIDatePicker) {
        defaults.set(NSCalendar.current.component(Calendar.Component.hour, from: sender.date), forKey: "DinnerNotifHour")
        defaults.set(NSCalendar.current.component(Calendar.Component.minute, from: sender.date), forKey: "DinnerNotifMin")
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dinnerRequest"])
            if (!UniversalMethods.dinnerNotifPassed(defaults: self.defaults)) {
                UniversalMethods.addUNNotif(hour: defaults.integer(forKey: "DinnerNotifHour"), minute: defaults.integer(forKey: "DinnerNotifMin"), text: defaults.string(forKey: "Dinner")!.components(separatedBy: "<")[0], title: "Dinner Today", id: "dinner", noMealString: FetchData().noMealString)
            }
        }
    }
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: {()->Void in
            self.presentingViewController?.dismiss(animated: true, completion: nil);
        });
    }
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBAction func resetButton(_ sender: UIBarButtonItem) {
        defaults.set(true, forKey: "LunchNotifOn")
        defaults.set(true, forKey: "DinnerNotifOn")
        defaults.set(9, forKey: "LunchNotifHour")
        defaults.set(55, forKey: "LunchNotifMin")
        defaults.set(16, forKey: "DinnerNotifHour")
        defaults.set(00, forKey: "DinnerNotifMin")
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["lunchRequest"])
            if (!UniversalMethods.lunchNotifPassed(defaults: self.defaults)) {
                UniversalMethods.addUNNotif(hour: defaults.integer(forKey: "LunchNotifHour"), minute: defaults.integer(forKey: "LunchNotifMin"), text: defaults.string(forKey: "Lunch")!.components(separatedBy: "<")[0], title: "Lunch Today", id: "lunch", noMealString: FetchData().noMealString)
            
            }
        
        
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dinnerRequest"])
            if (!UniversalMethods.dinnerNotifPassed(defaults: self.defaults)) {
                UniversalMethods.addUNNotif(hour: defaults.integer(forKey: "DinnerNotifHour"), minute: defaults.integer(forKey: "DinnerNotifMin"), text: defaults.string(forKey: "Dinner")!.components(separatedBy: "<")[0], title: "Dinner Today", id: "dinner", noMealString: FetchData().noMealString)
            }
            
        }
    
        setUIElements()
    }
    
    override func viewDidLoad() {
        setUIElements()
        if #available(iOS 10.0, *){
            navigationItem.prompt = nil
        }
        else{
            navigationItem.prompt = "Notifications Not Supported on iOS 9"
            resetButton.isEnabled = false
            lunchNotifLabel.text = "No Settings Available"
            dinnerNotifLabel.isHidden = true
            lunchNotifSwitch.isHidden = true
            dinnerNotifSwitch.isHidden = true
            lunchNotifTimePicker.isHidden = true
            dinnerNotifTimePicker.isHidden = true
        }
    }
    
    func setUIElements() {
        lunchNotifSwitch.isOn = defaults.bool(forKey: "LunchNotifOn")
        dinnerNotifSwitch.isOn = defaults.bool(forKey: "DinnerNotifOn")
        
        var dcL = DateComponents()
        dcL.hour = defaults.integer(forKey: "LunchNotifHour")
        dcL.minute = defaults.integer(forKey: "LunchNotifMin")
        lunchNotifTimePicker.setDate(Calendar.current.date(from: dcL)!, animated: true)
        
        var dcD = DateComponents()
        dcD.hour = defaults.integer(forKey: "DinnerNotifHour")
        dcD.minute = defaults.integer(forKey: "DinnerNotifMin")
        dinnerNotifTimePicker.setDate(Calendar.current.date(from: dcD)!, animated: true)
    }
}
