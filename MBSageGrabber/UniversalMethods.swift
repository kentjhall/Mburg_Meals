//
//  UniversalMethods.swift
//  MBSageGrabber
//
//  Created by Kent Hall on 12/22/16.
//  Copyright © 2016 kentahallis. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration
import UserNotifications

class UniversalMethods{
    
    static func setMealLabel(mealLabel:UILabel, mealTitleLabel:UILabel, dateLabel:UILabel, navigationItem:UINavigationItem, loadWheelVC:UIActivityIndicatorView, prevButton:UIBarButtonItem, nextButton:UIBarButtonItem, subView:UIView?, tableView:UITableView?, defaults: UserDefaults, resNavItem: Bool, text:String){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        var attributedString = NSMutableAttributedString()
        
        attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        mealLabel.attributedText = attributedString
        
        if (subView != nil && tableView != nil){
            subView?.frame = CGRect(x: (subView?.frame.origin.x)!, y: (subView?.frame.origin.y)!, width: (subView?.frame.width)!, height: CGFloat((text.components(separatedBy: "\n").count))*30.6)
            tableView?.reloadData()
        }
        
        mealTitleLabel.isHidden = false
        mealLabel.isHidden = false
        dateLabel.isHidden = false
        if resNavItem{
            defaults.set(nil, forKey: "navItemPromptU")
        }
        navigationItem.prompt = defaults.string(forKey: "navItemPromptU")
        loadWheelVC.stopAnimating()
        prevButton.isEnabled=false
        nextButton.isEnabled=true
    }
    
    static func setMealLabel(mealLabel:UILabel, navigationItem:UINavigationItem?, subView:UIView?, tableView:UITableView?, text:String){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        var attributedString = NSMutableAttributedString()
        
        attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        mealLabel.attributedText = attributedString
        if (navigationItem != nil){
            if navigationItem?.prompt=="Loading..."{
                navigationItem?.prompt = nil
            }
        }
        
        if (subView != nil && tableView != nil){
            subView?.frame = CGRect(x: (subView?.frame.origin.x)!, y: (subView?.frame.origin.y)!, width: (subView?.frame.width)!, height: CGFloat((text.components(separatedBy: "\n").count))*30.6)
            tableView?.reloadData()
        }
    }
    
    static func loadDataVC(fetchData: inout FetchData, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem, defaults: UserDefaults, dateLabel: UILabel, navigationItem: UINavigationItem, mealTitleLabel: UILabel, mealLabel: UILabel, loadWheel: UIActivityIndicatorView, refreshControl: UIRefreshControl, subView: UIView, tableView: UITableView, mealType: FetchData.MealType) {
        fetchData = FetchData()
        prevButton.isEnabled = false
        nextButton.isEnabled = true
        dateLabel.text = defaults.string(forKey: "Date")
        navigationItem.prompt = defaults.string(forKey: "navItemPromptU")
        if (UniversalMethods.connectedToNetwork()){
            if (defaults.integer(forKey: "Day") != NSCalendar.current.component(Calendar.Component.day, from: Date())){
                fetchData.initLoad(mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, dateLabel:dateLabel, loadWheel:loadWheel, refreshControl:refreshControl, navigationItem:navigationItem, prevButton:prevButton, nextButton:nextButton, subView:subView, tableView:tableView, jsExec: "", jsExecCount: 0, mealType: mealType)
                if (mealTitleLabel.isHidden){
                    mealLabel.isHidden = true
                    dateLabel.isHidden = true
                    defaults.set("Loading...", forKey: "navItemPromptU")
                    navigationItem.prompt = defaults.string(forKey: "navItemPromptU")
                    loadWheel.startAnimating()
                    prevButton.isEnabled=false
                    nextButton.isEnabled=false
                }
            }
            else{
                mealTitleLabel.isHidden = false
                mealLabel.isHidden = false
                dateLabel.isHidden = false
                defaults.set(nil, forKey: "navItemPromptU")
                navigationItem.prompt = defaults.string(forKey: "navItemPromptU")
                loadWheel.stopAnimating()
            }
        }
        else{
            defaults.set("No Internet Connection | Pull to Refresh", forKey: "navItemPromptU")
            navigationItem.prompt = defaults.string(forKey: "navItemPromptU")
        }
        if (defaults.string(forKey: mealType.rawValue) != nil){
            UniversalMethods.setMealLabel(mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, dateLabel: dateLabel, navigationItem: navigationItem, loadWheelVC: loadWheel, prevButton: prevButton, nextButton: nextButton, subView: subView, tableView: tableView, defaults: defaults, resNavItem: false, text: defaults.string(forKey: mealType.rawValue)!)
        }
        if (defaults.integer(forKey: "DaysForward") != 0 || defaults.bool(forKey: "ShowingTomorrow")){
            UniversalMethods.selMealToLabel(dateLabel: dateLabel, prevButton: prevButton, nextButton: nextButton, defaults: defaults, fetchData: fetchData, mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, navigationItem: navigationItem, refreshControl: refreshControl, loadWheel: loadWheel, subView: subView, tableView: tableView, mealType: mealType)
        }
        
        if NSCalendar.current.component(Calendar.Component.hour, from: Date()) >= 19 && !prevButton.isEnabled && !mealTitleLabel.isHidden && defaults.string(forKey: mealType.rawValue) != nil && !defaults.bool(forKey: "ShowingTomorrow") {
            UniversalMethods.nextMealToLabel(dateLabel: dateLabel, prevButton: prevButton, nextButton: nextButton, defaults: defaults, fetchData: fetchData, mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, navigationItem: navigationItem, refreshControl: refreshControl, loadWheel: loadWheel, subView: subView, tableView: tableView, mealType: mealType)
            defaults.set(true, forKey: "ShowingTomorrow")
        }
        else if NSCalendar.current.component(Calendar.Component.hour, from: Date()) < 19 && prevButton.isEnabled && defaults.bool(forKey: "ShowingTomorrow") {
            prevMealToLabel(dateLabel: dateLabel, prevButton: prevButton, nextButton: nextButton, defaults: defaults, fetchData: fetchData, mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, refreshControl: refreshControl, loadWheel: loadWheel, mealType: mealType)
            defaults.set(false, forKey: "ShowingTomorrow")
        }
    }
    
    static func refreshAction(defaults: UserDefaults, fetchData: inout FetchData, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem, dateLabel: UILabel, navigationItem: UINavigationItem, mealTitleLabel: UILabel, mealLabel: UILabel, loadWheel: UIActivityIndicatorView, refreshControl: UIRefreshControl, subView: UIView, tableView: UITableView, mealType: FetchData.MealType) {
        defaults.set(false, forKey: "ShowingTomorrow")
        defaults.set(0, forKey: "DaysForward")
        UniversalMethods.loadDataVC(fetchData: &fetchData, prevButton: prevButton, nextButton: nextButton, defaults: defaults, dateLabel: dateLabel, navigationItem: navigationItem, mealTitleLabel: mealTitleLabel, mealLabel: mealLabel, loadWheel: loadWheel, refreshControl: refreshControl, subView: subView, tableView: tableView, mealType: mealType)
        if (fetchData.defaults.integer(forKey: "Day") == NSCalendar.current.component(Calendar.Component.day, from: Date()) || !UniversalMethods.connectedToNetwork()){
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                refreshControl.endRefreshing();
            }
        }
    }
    
    static func prevMealToLabel(dateLabel: UILabel, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem, defaults: UserDefaults, fetchData: FetchData, mealLabel: UILabel, mealTitleLabel: UILabel, navigationItem: UINavigationItem, subView: UIView, tableView: UITableView, refreshControl: UIRefreshControl, loadWheel: UIActivityIndicatorView, mealType: FetchData.MealType) {
        let tempDate = dateFromDefaults(defaults: defaults)
        var daysForward = defaults.integer(forKey: "DaysForward")
        if (daysForward>=1){
            daysForward -= 1
            dateLabel.text = "*" + incDateString(by: daysForward, to: tempDate)
            if (daysForward==0){
                prevButton.isEnabled=false
                nextButton.isEnabled=true
                dateLabel.text = dateLabel.text?.replacingOccurrences(of: "*", with: "")
            }
            else{
                prevButton.isEnabled=true
                nextButton.isEnabled=true
            }
        }
        if (daysForward>=1 && daysForward<=7){
            if (defaults.string(forKey: "\(mealType.rawValue)\(daysForward)") != nil){
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: defaults.string(forKey: "\(mealType.rawValue)\(daysForward)")!)
            }
            else{
                fetchData.initLoad(mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, dateLabel: dateLabel, loadWheel: loadWheel, refreshControl: refreshControl, navigationItem:navigationItem, prevButton: prevButton, nextButton: nextButton, subView: subView, tableView: tableView, jsExec: "document.execCommand($('#somDateNavNext').click())", jsExecCount: daysForward, mealType: mealType)
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: "")
                navigationItem.prompt = "Loading..."
            }
        }
        else if (daysForward<1){
            if (defaults.string(forKey: "\(mealType.rawValue)") != nil){
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: defaults.string(forKey: "\(mealType.rawValue)")!)
            }
        }
        defaults.set(false, forKey: "ShowingTomorrow")
        defaults.set(daysForward, forKey: "DaysForward")
    }
    
    static func nextMealToLabel(dateLabel: UILabel, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem, defaults: UserDefaults, fetchData: FetchData, mealLabel: UILabel, mealTitleLabel: UILabel, navigationItem: UINavigationItem, refreshControl: UIRefreshControl, loadWheel: UIActivityIndicatorView, subView: UIView, tableView: UITableView, mealType: FetchData.MealType) {
        let tempDate = dateFromDefaults(defaults: defaults)
        var daysForward = defaults.integer(forKey: "DaysForward")
        if (daysForward<7){
            daysForward += 1
            dateLabel.text = "*" + incDateString(by: daysForward, to: tempDate)
            if (daysForward==7){
                nextButton.isEnabled=false
                prevButton.isEnabled=true
            }
            else{
                nextButton.isEnabled=true
                prevButton.isEnabled=true
            }
        }
        if (daysForward>=1 && daysForward<=7){
            if (defaults.string(forKey: "\(mealType.rawValue)\(daysForward)") != nil){
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: defaults.string(forKey: "\(mealType.rawValue)\(daysForward)")!)
            }
            else{
                fetchData.initLoad(mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, dateLabel: dateLabel, loadWheel: loadWheel, refreshControl:refreshControl, navigationItem:navigationItem, prevButton: prevButton, nextButton: nextButton, subView: subView, tableView: tableView, jsExec: "document.execCommand($('#somDateNavNext').click())", jsExecCount: daysForward, mealType: mealType)
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: "")
                navigationItem.prompt = "Loading..."
            }
        }
        defaults.set(false, forKey: "ShowingTomorrow")
        defaults.set(daysForward, forKey: "DaysForward")
    }
    
    static func selMealToLabel (dateLabel: UILabel, prevButton: UIBarButtonItem, nextButton: UIBarButtonItem, defaults: UserDefaults, fetchData: FetchData, mealLabel: UILabel, mealTitleLabel: UILabel, navigationItem: UINavigationItem, refreshControl: UIRefreshControl, loadWheel: UIActivityIndicatorView, subView: UIView, tableView: UITableView, mealType: FetchData.MealType) {
        let tempDate = dateFromDefaults(defaults: defaults)
        let daysForward = defaults.integer(forKey: "DaysForward")
        dateLabel.text = "*" + incDateString(by: daysForward, to: tempDate)
        if (daysForward==7){
            nextButton.isEnabled=false
            prevButton.isEnabled=true
        }
        else{
            nextButton.isEnabled=true
            prevButton.isEnabled=true
        }
        if (daysForward>=1 && daysForward<=7){
            if (defaults.string(forKey: "\(mealType.rawValue)\(daysForward)") != nil){
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: defaults.string(forKey: "\(mealType.rawValue)\(daysForward)")!)
            }
            else{
                fetchData.initLoad(mealLabel: mealLabel, mealTitleLabel: mealTitleLabel, dateLabel: dateLabel, loadWheel: loadWheel, refreshControl:refreshControl, navigationItem:navigationItem, prevButton: prevButton, nextButton: nextButton, subView: subView, tableView: tableView, jsExec: "document.execCommand($('#somDateNavNext').click())", jsExecCount: daysForward, mealType: mealType)
                UniversalMethods.setMealLabel(mealLabel: mealLabel, navigationItem: navigationItem, subView: subView, tableView: tableView, text: "")
                navigationItem.prompt = "Loading..."
            }
        }
        defaults.set(daysForward, forKey: "DaysForward")
    }
    
    static func dateFromDefaults(defaults: UserDefaults) -> Date {
        var tempDateComps = DateComponents()
        tempDateComps.setValue(defaults.integer(forKey: "Day"), for: .day)
        tempDateComps.setValue(defaults.integer(forKey: "Month"), for: .month)
        tempDateComps.setValue(NSCalendar.current.component(.year, from: Date()), for: .year)
        return NSCalendar.current.date(from: tempDateComps)!
    }
    
    static func incDateString(by: Int, to: Date) -> String{
        return "\(UniversalMethods.weekDayToString(date: Calendar.current.date(byAdding: .day, value: by, to: to)!)) \(UniversalMethods.monthToShortString(date: Calendar.current.date(byAdding: .day, value: by, to: to)!)) \(UniversalMethods.dayWithEnding(date: Calendar.current.date(byAdding: .day, value: by, to: to)!))"
    }
    
    static func addUNNotif(hour:Int, minute:Int, text:String, title:String, id:String, noMealString:String){
        if #available(iOS 10.0, *){
            if (text != noMealString) {
                // Create the trigger for the notification
                let date = NSDateComponents()
                date.hour = hour
                date.minute = minute
                let trigger = UNCalendarNotificationTrigger.init(dateMatching: date as DateComponents, repeats: false)
                
                // Create the content for the local notification
                let unContent = UNMutableNotificationContent()
                unContent.title = title
                unContent.body = text
                
                // Add the notification to the notification system.
                let unRequest = UNNotificationRequest(identifier: "\(id)Request", content: unContent, trigger: trigger)
                UNUserNotificationCenter.current().add(unRequest) { (error) in
                    // handle the error if needed
                    print(error)
                }
            }
        }
    }
    
    static func lunchNotifPassed(defaults: UserDefaults)->Bool{
        if ((NSCalendar.current.component(Calendar.Component.hour, from: Date()) < defaults.integer(forKey: "LunchNotifHour") || (NSCalendar.current.component(Calendar.Component.hour, from: Date()) == defaults.integer(forKey: "LunchNotifHour") && NSCalendar.current.component(Calendar.Component.minute, from: Date()) < defaults.integer(forKey: "LunchNotifMin"))) && defaults.bool(forKey: "LunchNotifOn")){
            return false
        }
        else{
            return true
        }
    }
    
    static func dinnerNotifPassed(defaults: UserDefaults)->Bool{
        if ((NSCalendar.current.component(Calendar.Component.hour, from: Date()) < defaults.integer(forKey: "DinnerNotifHour") || (NSCalendar.current.component(Calendar.Component.hour, from: Date()) == defaults.integer(forKey: "DinnerNotifHour") && NSCalendar.current.component(Calendar.Component.minute, from: Date()) < defaults.integer(forKey: "DinnerNotifMin"))) && defaults.bool(forKey: "DinnerNotifOn")){
            return false
        }
        else{
            return true
        }
    }
    
    static func monthToShortString(date: Date) -> String{
        switch NSCalendar.current.component(Calendar.Component.month, from: date) {
        case 1:
            return "Jan"
        case 2:
            return "Feb"
        case 3:
            return "Mar"
        case 4:
            return "Apr"
        case 5:
            return "May"
        case 6:
            return "Jun"
        case 7:
            return "Jul"
        case 8:
            return "Aug"
        case 9:
            return "Sep"
        case 10:
            return "Oct"
        case 11:
            return "Nov"
        case 12:
            return "Dec"
        default:
            return "null"
        }
    }
    
    static func dayWithEnding(date: Date) -> String{
        switch NSCalendar.current.component(Calendar.Component.day, from: date) {
        case 1:
            return "1st"
        case 2:
            return "2nd"
        case 3:
            return "3rd"
        case 21:
            return "21st"
        case 22:
            return "22nd"
        case 23:
            return "23rd"
        case 31:
            return "31st"
        default:
            return "\(NSCalendar.current.component(Calendar.Component.day, from: date))th"
        }
    }
    
    static func weekDayToString(date: Date) -> String{
        switch NSCalendar.current.component(Calendar.Component.weekday, from: date) {
        case 1:
            return "Sunday"
        case 2:
            return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "null"
        }
    }

    static func connectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}
