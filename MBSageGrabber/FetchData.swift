//
//  FetchData.swift
//  MBSageGrabber
//
//  Created by Kent Hall on 9/25/16.
//  Copyright © 2016 kentahallis. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import UserNotifications
import SystemConfiguration

class FetchData: NSObject, WKNavigationDelegate {
    var items:[String] = [""]
    var mainItem:[String] = [""]
    var webView:WKWebView?
    var loadDelay:Double = 0
    var tries:Int = 0;
    var timeout:Double = 0;
    var defaults = UserDefaults(suiteName: "group.grabberData")!
    var loadWheelWidget:UIActivityIndicatorView?
    var loadWheelVC:UIActivityIndicatorView?
    var refreshControl:UIRefreshControl?
    var breakfastLabel:UILabel?
    var lunchLabel:UILabel?
    var dinnerLabel:UILabel?
    var breakfastTitleLabel:UILabel?
    var lunchTitleLabel:UILabel?
    var dinnerTitleLabel:UILabel?
    var dateLabel:UILabel?
    var navigationItem:UINavigationItem?
    var prevButton:UIBarButtonItem?
    var nextButton:UIBarButtonItem?
    var subView:UIView?
    var tableView: UITableView?
    var updateLabels:Bool = false
    var multiLine:Bool = false
    var isWidget:Bool = false
    let noMealString:String = "¯\\_(ツ)_/¯"
    let labelWidth = Int(UIScreen.main.bounds.width*0.9146666667)
    var jsExec:String = ""
    var jsExecCount:Int = 0
    var htmlDate:Date?
    var mealType:MealType?
    enum MealType:String {
        case BREAKFAST = "Breakfast"
        case LUNCH = "Lunch"
        case DINNER = "Dinner"
    }

    func initLoad(){
        let url = URL(string:"http://www.sagedining.com/menus/mercersburgacademy/")
        let req = URLRequest(url: url!)
        
        cycleFutureMeals()
        let webView = WKWebView()
        webView.navigationDelegate = self
        self.webView = webView
        webView.load(req)
        timeout=0;
        defaults.set(true, forKey: "IsLoading")
        NSLog("load initiated")
    }
    
    func initLoad(breakfastLabel:UILabel, lunchLabel:UILabel, dinnerLabel:UILabel, dateLabel:UILabel, loadWheel:UIActivityIndicatorView){
        let url = URL(string:"http://www.sagedining.com/menus/mercersburgacademy/")
        let req = URLRequest(url: url!)
        
        self.loadWheelWidget = loadWheel
        self.breakfastLabel = breakfastLabel
        self.lunchLabel = lunchLabel
        self.dinnerLabel = dinnerLabel
        self.dateLabel = dateLabel
        updateLabels = true
        
        if self.defaults.integer(forKey: "DayLastUpdate") != NSCalendar.current.component(Calendar.Component.day, from: Date()) {
            self.loadWheelWidget?.startAnimating()
        }
        cycleFutureMeals()
        let webView = WKWebView()
        webView.navigationDelegate = self
        self.webView = webView
        webView.load(req)
        isWidget = true
        timeout=10;
        defaults.set(true, forKey: "IsLoading")
    }
    
    func initLoad(mealLabel:UILabel, mealTitleLabel:UILabel, dateLabel:UILabel, loadWheel:UIActivityIndicatorView, refreshControl:UIRefreshControl, navigationItem:UINavigationItem, prevButton:UIBarButtonItem, nextButton:UIBarButtonItem, subView:UIView, tableView:UITableView, jsExec:String, jsExecCount:Int, mealType:MealType){
        let url = URL(string:"http://www.sagedining.com/menus/mercersburgacademy/")
        let req = URLRequest(url: url!)
        
        self.loadWheelVC = loadWheel
        self.refreshControl = refreshControl
        self.dateLabel = dateLabel
        self.navigationItem = navigationItem
        self.subView = subView
        self.tableView = tableView
        self.prevButton = prevButton
        self.nextButton = nextButton
        updateLabels = true
        multiLine = true
        self.jsExec = jsExec
        self.jsExecCount = jsExecCount
        
        cycleFutureMeals()
        let webView = WKWebView()
        webView.navigationDelegate = self
        self.webView = webView
        webView.load(req)
        timeout=10;
        defaults.set(true, forKey: "IsLoading")
        
        switch mealType {
            case MealType.BREAKFAST:
                self.breakfastLabel = mealLabel
                self.breakfastTitleLabel = mealTitleLabel
                break;
            case MealType.LUNCH:
                self.lunchLabel = mealLabel
                self.lunchTitleLabel = mealTitleLabel
                break;
            case MealType.DINNER:
                self.dinnerLabel = mealLabel
                self.dinnerTitleLabel = mealTitleLabel
                break;
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout){
            if self.defaults.integer(forKey: "DayLastUpdate") != NSCalendar.current.component(Calendar.Component.day, from: Date()) {
                if refreshControl.isRefreshing || loadWheel.isAnimating {
                    self.defaults.set("Error | Pull to Refresh", forKey: "navItemPromptU")
                    navigationItem.prompt = self.defaults.string(forKey: "navItemPromptU")
                }
                loadWheel.stopAnimating()
                refreshControl.endRefreshing()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("WV Load Finished")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()/* + loadDelay*/){
            if (self.jsExecCount>0){
                for _ in 1...self.jsExecCount{
                    webView.evaluateJavaScript(self.jsExec, completionHandler: nil)
                }
            }
            webView.evaluateJavaScript("document.body.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
                var doneLoading = self.htmlToString(html: html, daysAhead: 0).doneLoading
                if (doneLoading){
                    var mealString:String
                    if (self.jsExecCount>0){
                        mealString = self.htmlStringToMenu(meal: "Lunch\(self.jsExecCount)")
                    }
                    else{
                        mealString = self.htmlStringToMenu(meal: "Lunch")
                    }
                    if (self.updateLabels && (self.lunchLabel != nil)){
                        if (self.subView != nil && self.tableView != nil){
                            if (self.jsExec=="" && self.defaults.integer(forKey: "DaysForward") == 0){
                                UniversalMethods.setMealLabel(mealLabel: self.lunchLabel!, mealTitleLabel: self.lunchTitleLabel!, dateLabel: self.dateLabel!, navigationItem: self.navigationItem!, loadWheelVC: self.loadWheelVC!, prevButton: self.prevButton!, nextButton: self.nextButton!, subView: self.subView, tableView: self.tableView, defaults: self.defaults, resNavItem: true, text: mealString)
                            }
                            else if self.jsExecCount>0 {
                                UniversalMethods.setMealLabel(mealLabel: self.lunchLabel!, navigationItem: self.navigationItem, subView: self.subView!, tableView: self.tableView!, text: mealString)
                            }
                        }
                        else{
                            UniversalMethods.setMealLabel(mealLabel: self.lunchLabel!, navigationItem: self.navigationItem, subView: nil, tableView: nil, text: mealString)
                        }
                    }
                    if (self.updateLabels && self.jsExec == "" && self.htmlDate != nil && (self.defaults.integer(forKey: "DaysForward") == 0 || self.isWidget)){
                        let date = self.htmlDate!
                        self.dateLabel?.text = "\(UniversalMethods.weekDayToString(date: date)) \(UniversalMethods.monthToShortString(date: date)) \(UniversalMethods.dayWithEnding(date: date))"
                    }
                    if self.jsExec=="" && self.htmlDate != nil {
                        let date = self.htmlDate!
                        self.defaults.setValue("\(UniversalMethods.weekDayToString(date: date)) \(UniversalMethods.monthToShortString(date: date)) \(UniversalMethods.dayWithEnding(date: date))", forKey: "Date")
                        self.defaults.setValue(NSCalendar.current.component(Calendar.Component.month, from: date), forKey: "Month")
                        self.defaults.setValue(NSCalendar.current.component(Calendar.Component.day, from: date), forKey: "Day")
                        self.defaults.setValue(NSCalendar.current.component(Calendar.Component.day, from: Date()), forKey: "DayLastUpdate")
                        self.defaults.setValue(NSCalendar.current.component(Calendar.Component.day, from: Date()), forKey: "MonthLastUpdate")
                        self.defaults.set(0, forKey: "DaysFurtherFuture")
                        self.defaults.set(true, forKey: "WebRefreshedToday")
                    }
                    if self.jsExecCount > 0 {
                        if self.htmlDate != nil {
                            let date = self.htmlDate!
                            self.defaults.set("\(UniversalMethods.weekDayToString(date: date)) \(UniversalMethods.monthToShortString(date: date)) \(UniversalMethods.dayWithEnding(date: date))", forKey: "Date\(self.jsExecCount)")
                        }
                        if self.defaults.string(forKey: "Date\(self.jsExecCount)") != nil {
                            self.dateLabel?.text = "*" + self.defaults.string(forKey: "Date\(self.jsExecCount)")!
                        }
                    }
                    webView.evaluateJavaScript("document.execCommand($('#somMealNavItem2').click())", completionHandler: nil)
                    webView.evaluateJavaScript("document.body.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
                        doneLoading = self.htmlToString(html: html, daysAhead: 0).doneLoading
                        if (doneLoading){
                            if (self.jsExecCount>0){
                                mealString = self.htmlStringToMenu(meal: "Dinner\(self.jsExecCount)")
                            }
                            else{
                                mealString = self.htmlStringToMenu(meal: "Dinner")
                            }

                            if (self.updateLabels && (self.dinnerLabel != nil)){
                                if (self.subView != nil && self.tableView != nil){
                                    if (self.jsExec=="" && self.defaults.integer(forKey: "DaysForward") == 0){
                                        UniversalMethods.setMealLabel(mealLabel: self.dinnerLabel!, mealTitleLabel: self.dinnerTitleLabel!, dateLabel: self.dateLabel!, navigationItem: self.navigationItem!, loadWheelVC: self.loadWheelVC!, prevButton: self.prevButton!, nextButton: self.nextButton!, subView: self.subView, tableView: self.tableView, defaults: self.defaults, resNavItem: true, text: mealString)
                                    }
                                    else if self.jsExecCount>0 {
                                        UniversalMethods.setMealLabel(mealLabel: self.dinnerLabel!, navigationItem: self.navigationItem, subView: self.subView!, tableView: self.tableView!, text: mealString)
                                    }
                                }
                                else{
                                    UniversalMethods.setMealLabel(mealLabel: self.dinnerLabel!, navigationItem: self.navigationItem, subView: nil, tableView: nil, text: mealString)
                                }
                            }
                        }
                        webView.evaluateJavaScript("document.execCommand($('#somMealNavItem0').click())", completionHandler: nil)
                        webView.evaluateJavaScript("document.body.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
                            doneLoading = self.htmlToString(html: html, daysAhead: 0).doneLoading
                            if (doneLoading){
                                if (self.jsExecCount>0){
                                    mealString = self.htmlStringToMenu(meal: "Breakfast\(self.jsExecCount)")
                                }
                                else{
                                    mealString = self.htmlStringToMenu(meal: "Breakfast")
                                }
                                
                                if (self.updateLabels && (self.breakfastLabel != nil)){
                                    if (self.subView != nil && self.tableView != nil){
                                        if (self.jsExec=="" && self.defaults.integer(forKey: "DaysForward") == 0){
                                            UniversalMethods.setMealLabel(mealLabel: self.breakfastLabel!, mealTitleLabel: self.breakfastTitleLabel!, dateLabel: self.dateLabel!, navigationItem: self.navigationItem!, loadWheelVC: self.loadWheelVC!, prevButton: self.prevButton!, nextButton: self.nextButton!, subView: self.subView, tableView: self.tableView, defaults: self.defaults, resNavItem: true, text: mealString)
                                        }
                                        else if self.jsExecCount>0 {
                                            UniversalMethods.setMealLabel(mealLabel: self.breakfastLabel!, navigationItem: self.navigationItem, subView: self.subView!, tableView: self.tableView!, text: mealString)
                                        }
                                        
                                    }
                                    else{
                                        UniversalMethods.setMealLabel(mealLabel: self.breakfastLabel!, navigationItem: self.navigationItem, subView: nil, tableView: nil, text: mealString)
                                    }
                                }
                                if (self.jsExec==""){
                                    var lastHtml = ["", "", ""]
                                    for i in 1...7 {
                                        webView.evaluateJavaScript("document.execCommand($('#somDateNavNext').click())", completionHandler: nil)
                                        for j in 0...2{
                                            var mealString = ""
                                            switch j {
                                            case 0:
                                                mealString = "Breakfast"
                                                break
                                            case 1:
                                                mealString = "Lunch"
                                                break
                                            case 2:
                                                mealString = "Dinner"
                                                break
                                            default:
                                                mealString = ""
                                            }
                                            webView.evaluateJavaScript("document.execCommand($('#somMealNavItem\(j)').click())", completionHandler: nil)
                                            webView.evaluateJavaScript("document.body.outerHTML.toString()", completionHandler: { (html: Any?, error: Error?) in
                                                let htmlString = html != nil ? html! as! String : ""
                                                let retTuple = self.htmlToString(html: html, daysAhead: i)
                                                doneLoading = retTuple.doneLoading
                                                let date = retTuple.date
                                                if htmlString == lastHtml[j] {
                                                    self.htmlToString(html: "", daysAhead: i)
                                                }
                                                lastHtml[j] = htmlString
                                                if doneLoading{
                                                    self.htmlStringToMenu(meal: "\(mealString)\(i)")
                                                    if date != nil {
                                                        self.defaults.set("\(UniversalMethods.weekDayToString(date: date!)) \(UniversalMethods.monthToShortString(date: date!)) \(UniversalMethods.dayWithEnding(date: date!))", forKey: "Date\(i)")
                                                    }
                                                }
                                                else{
                                                    self.defaults.setValue(nil, forKey: "\(mealString)\(i)")
                                                    if self.jsExecCount == 0 {
                                                        self.defaults.set(nil, forKey: "Date\(i)")
                                                    }
                                                }
                                                /**** TESTING ****/
//                                                self.defaults.setValue(nil, forKey: "Lunch\(3)")
//                                                self.defaults.setValue(nil, forKey: "Dinner\(3)")
//                                                self.defaults.setValue(nil, forKey: "Breakfast\(3)")
                                                /**** TESTING ****/
                                            })
                                        }
                                    }
                                }
                            }
                            
                            self.loadWheelWidget?.stopAnimating()
                            self.loadWheelVC?.stopAnimating()
                            self.refreshControl?.endRefreshing()
                            self.defaults.set(nil, forKey: "navItemPromptU")
                            self.navigationItem?.prompt = self.defaults.string(forKey: "navItemPromptU")
                            self.defaults.set(false, forKey: "IsLoading")
                            if #available(iOS 10.0, *) {
                                if (!UniversalMethods.lunchNotifPassed(defaults: self.defaults)) {
                                    UniversalMethods.addUNNotif(hour: self.defaults.integer(forKey: "LunchNotifHour"), minute: self.defaults.integer(forKey: "LunchNotifMin"), text: self.defaults.string(forKey: "Lunch")!.components(separatedBy: "<")[0], title: "Lunch Today", id: "lunch", noMealString: self.noMealString, defaults: self.defaults)
                                }
                                if (!UniversalMethods.dinnerNotifPassed(defaults: self.defaults)) {
                                    UniversalMethods.addUNNotif(hour: self.defaults.integer(forKey: "DinnerNotifHour"), minute: self.defaults.integer(forKey: "DinnerNotifMin"), text: self.defaults.string(forKey: "Dinner")!.components(separatedBy: "<")[0], title: "Dinner Today", id: "dinner", noMealString: self.noMealString, defaults: self.defaults)
                                }
                                NSLog("Web refresh notifs added")
                            }
                        })
                    })
                }
                else{
                    webView.reload()
                    if (self.loadDelay<2 && self.tries>=2){
                        self.loadDelay+=0.5
                    }
                    self.tries+=1
                }
            })
        }
    }

    func cycleFutureMeals() {
        let tempDate = UniversalMethods.dateFromDefaults(defaults: defaults)
        let daysFurther = NSCalendar.current.dateComponents([Calendar.Component.day], from: tempDate, to: Date()).day!
        if daysFurther > 0 {
            if (defaults.string(forKey: "Breakfast\(daysFurther)") != nil) && (defaults.string(forKey: "Lunch\(daysFurther)") != nil) && (defaults.string(forKey: "Dinner\(daysFurther)") != nil){
                movDownMeals(meal: "Breakfast", daysFurther: daysFurther)
                movDownMeals(meal: "Lunch", daysFurther: daysFurther)
                movDownMeals(meal: "Dinner", daysFurther: daysFurther)
                movDownMeals(meal: "Date", daysFurther: daysFurther)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                    self.refreshControl?.endRefreshing();
                }
//                self.defaults.setValue("\(UniversalMethods.weekDayToString(date: Date())) \(UniversalMethods.monthToShortString(date: Date())) \(UniversalMethods.dayWithEnding(date: Date()))", forKey: "Date")
                self.defaults.setValue(NSCalendar.current.component(Calendar.Component.month, from: Date()), forKey: "Month")
                self.defaults.setValue(NSCalendar.current.component(Calendar.Component.day, from: Date()), forKey: "Day")
                self.defaults.setValue(NSCalendar.current.component(Calendar.Component.month, from: Date()), forKey: "MonthLastUpdate")
                self.defaults.setValue(NSCalendar.current.component(Calendar.Component.day, from: Date()), forKey: "DayLastUpdate")
                
                dateLabel?.text = defaults.string(forKey: "Date")
                self.loadWheelVC?.stopAnimating()
                self.loadWheelWidget?.stopAnimating()
                
                if #available(iOS 10.0, *) {
                    if (!UniversalMethods.lunchNotifPassed(defaults: self.defaults) && self.defaults.string(forKey: "Lunch") != nil) {
                        UniversalMethods.addUNNotif(hour: self.defaults.integer(forKey: "LunchNotifHour"), minute: self.defaults.integer(forKey: "LunchNotifMin"), text: self.defaults.string(forKey: "Lunch")!.components(separatedBy: "<")[0], title: "Lunch Today", id: "lunch", noMealString: self.noMealString, defaults: self.defaults)
                    }
                    if (!UniversalMethods.dinnerNotifPassed(defaults: self.defaults) && self.defaults.string(forKey: "Dinner") != nil) {
                        UniversalMethods.addUNNotif(hour: self.defaults.integer(forKey: "DinnerNotifHour"), minute: self.defaults.integer(forKey: "DinnerNotifMin"), text: self.defaults.string(forKey: "Dinner")!.components(separatedBy: "<")[0], title: "Dinner Today", id: "dinner", noMealString: self.noMealString, defaults: self.defaults)
                    }
                }
                NSLog("Future meals cycled, notifs added")
            }
        }
    }
    
    func movDownMeals(meal: String, daysFurther: Int) {
        if daysFurther+1 <= 8 {
            defaults.set(defaults.string(forKey: "\(meal)\(daysFurther)"), forKey: "\(meal)")
            for i in (daysFurther+1)...8 {
                if defaults.string(forKey: "\(meal)\(i)") != nil {
                    defaults.set(defaults.string(forKey: "\(meal)\(i)"), forKey: "\(meal)\(i-daysFurther)")
                }
                else{
                    defaults.set(nil, forKey: "\(meal)\(i-daysFurther)")
                    for n in (i+1)-daysFurther...8 {
                        defaults.set(nil, forKey: "\(meal)\(n)")
                    }
                }
            }
        }
        else {
            defaults.set(nil, forKey: "Lunch")
            for i in 1...7 {
                defaults.set(nil, forKey: "Lunch\(i)")
            }
        }
    }
    
    func htmlToString(html:Any?, daysAhead:Int) -> (doneLoading: Bool, date: Date?) {
        self.items = [""]
        self.mainItem = [""]
        var htmlString = html != nil ? html! as! String : ""
        let htmlDayString:String? = htmlString.components(separatedBy: "id=\"somDateNavDisplay\">").last?.components(separatedBy: "</div>").first?.components(separatedBy: "/").last
        let htmlMonthString:String? = htmlString.components(separatedBy: "id=\"somDateNavDisplay\">").last?.components(separatedBy: "</div>").first?.components(separatedBy: "/").first
        let htmlDay:Int? = htmlDayString != nil ? Int(htmlDayString!) : nil
        let htmlMonth:Int? = htmlMonthString != nil ? Int(htmlMonthString!) : nil
        if daysAhead == 0 {
            htmlDate = htmlMonth != nil && htmlDay != nil ? UniversalMethods.dateFromMD(month: htmlMonth!, day: htmlDay!) : nil
        }
//        let dateDaysAhead = NSCalendar.current.date(byAdding: .day, value: daysAhead, to: Date())
//        if htmlDay != nil && htmlDay != NSCalendar.current.component(.day, from: dateDaysAhead!) {
//            htmlString = "<div id=\"menuLoading\" class=\"noDisplay\">"
//        }
//        if htmlDay != nil && daysAhead == 0 && htmlDay != NSCalendar.current.component(.day, from: Date()) {
//            defaults.set(true, forKey: "NavButtonsDisabled")
//        }
//        else if htmlDay != nil && htmlDay == NSCalendar.current.component(.day, from: dateDaysAhead!) {
//            defaults.set(false, forKey: "NavButtonsDisabled")
//        }
        let doneLoading = htmlString.contains("<div id=\"menuLoading\" class=\"noDisplay\">")
        htmlString=htmlString.components(separatedBy: "id=\"somDailOfferingsWrapper\"")[0]
        htmlString=htmlString.replacingOccurrences(of: "&amp;", with: "&")
        self.items=htmlString.components(separatedBy: "<span class=\"menuItemAlias\">")
        if (self.items.count > 1){
            self.mainItem=self.items[1].components(separatedBy: "</span>")
        }
        if ((doneLoading || htmlString == "") && self.mainItem[0]=="") {
            self.mainItem[0] = noMealString
        }
        NSLog("meal: \(self.mainItem[0])")
        return (doneLoading, htmlMonth != nil && htmlDay != nil ? UniversalMethods.dateFromMD(month: htmlMonth!, day: htmlDay!) : nil)
    }
    
    func htmlStringToMenu(meal:String) -> String{
        self.mainItem = [self.mainItem[0]]
        var mealString = ""
        if (self.mainItem[0]==noMealString){
            mealString = self.mainItem[0]
        }
        if (self.items.count>=1){
        for i in 1..<self.items.count{
            var temp = self.items[i].components(separatedBy: "<")
            var tempLength = temp[0].characters.count;
            var tempString = temp[0]
            if (tempLength>Int(self.labelWidth/9)){
                tempLength = Int(self.labelWidth/9)
                tempString = temp[0].substring(to: temp[0].index(temp[0].startIndex, offsetBy: tempLength-3)) + "..."
            }
            if (self.items[i].range(of: "</ul>") != nil && i<self.items.count-1 && tempLength>1){
                mealString += "\n" + tempString + "\n"
                for _ in 1..<tempLength{
                    mealString += "–"
                }
            }
            else if tempLength != 0{
                if mealString != ""{
                    mealString += "\n"
                }
                mealString += tempString
            }
        }
        }
        self.defaults.setValue(mealString, forKey: meal)
        return mealString
    }
}
