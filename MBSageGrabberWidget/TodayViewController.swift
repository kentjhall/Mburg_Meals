//
//  TodayViewController.swift
//  MBSageGrabberWidget
//
//  Created by Kent Hall on 10/2/16.
//  Copyright © 2016 kentahallis. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBAction func tapReceiver(_ sender: UIControl) {
        self.extensionContext?.open(NSURL(string:"mbmeals://") as! URL, completionHandler: { (Bool) in
        })
    }
    @IBOutlet weak var loadWheel: UIActivityIndicatorView!
    @IBOutlet weak var breakfastTitleLabel: UILabel!
    @IBOutlet weak var breakfastLabel: UILabel!
    @IBOutlet weak var lunchTitleLabel: UILabel!
    @IBOutlet weak var lunchLabel: UILabel!
    @IBOutlet weak var dinnerTitleLabel: UILabel!
    @IBOutlet weak var dinnerLabel: UILabel!
        @IBOutlet weak var dateLabel: UILabel!
    var fetchData:FetchData = FetchData()
    var defaults = UserDefaults(suiteName: "group.grabberData")!

    override func viewDidLoad() {
        // Do any additional setup after loading the view from its nib.
        
        if #available(iOS 10.0, *){
            self.breakfastLabel.textColor = UIColor.black
            self.lunchLabel.textColor = UIColor.black
            self.dinnerLabel.textColor = UIColor.black
            self.breakfastTitleLabel.textColor = UIColor.black
            self.lunchTitleLabel.textColor = UIColor.black
            self.dinnerTitleLabel.textColor = UIColor.black
        }
        else{
            self.breakfastLabel.textColor = UIColor.white
            self.lunchLabel.textColor = UIColor.white
            self.dinnerLabel.textColor = UIColor.white
            self.dateLabel.textColor = UIColor.white
            self.breakfastTitleLabel.textColor = UIColor.white
            self.lunchTitleLabel.textColor = UIColor.white
            self.dinnerTitleLabel.textColor = UIColor.white
            
            var currentSize: CGSize = self.preferredContentSize
            currentSize.height = 80.0
            self.preferredContentSize = currentSize
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
        fetchData = FetchData()
        if (UniversalMethods.connectedToNetwork()){
            fetchData.initLoad(breakfastLabel: self.breakfastLabel, lunchLabel:self.lunchLabel, dinnerLabel:self.dinnerLabel, dateLabel:self.dateLabel, loadWheel:self.loadWheel)
            self.breakfastLabel.text = defaults.string(forKey: "Breakfast")?.components(separatedBy: "<")[0]
            self.lunchLabel.text = defaults.string(forKey: "Lunch")?.components(separatedBy: "<")[0]
            self.dinnerLabel.text = defaults.string(forKey: "Dinner")?.components(separatedBy: "<")[0]
            self.dateLabel.text = defaults.string(forKey: "Date")
            
            if NSCalendar.current.component(Calendar.Component.hour, from: Date()) >= 19 && (defaults.string(forKey: "Breakfast1") != nil) && (defaults.string(forKey: "Lunch1") != nil) && (defaults.string(forKey: "Dinner1") != nil) && defaults.string(forKey: "Date1") != nil && defaults.integer(forKey: "Day") == NSCalendar.current.component(.day, from: Date()) {
                self.breakfastLabel.text = defaults.string(forKey: "Breakfast1")?.components(separatedBy: "<")[0]
                self.lunchLabel.text = defaults.string(forKey: "Lunch1")?.components(separatedBy: "<")[0]
                self.dinnerLabel.text = defaults.string(forKey: "Dinner1")?.components(separatedBy: "<")[0]
                self.dateLabel.text = "*" + defaults.string(forKey: "Date1")! + " (Tomorrow)"
            }
        }
        else{
            self.dateLabel.text = "No Internet Connection"
            loadWheel.stopAnimating()
        }
    }
}
