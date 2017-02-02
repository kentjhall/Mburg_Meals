//
//  ViewController.swift
//  MBSageGrabber
//
//  Created by Kent Hall on 9/14/16.
//  Copyright © 2016 kentahallis. All rights reserved.
//

import UIKit
import SafariServices

class ViewControllerL: UIViewController{
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var mealTitleLabel: UILabel!
    @IBOutlet weak var mealLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBAction func webButton(_ sender: Any) {
        let svc = SFSafariViewController(url: self.url!)
        if #available(iOS 10.0, *) {
            svc.preferredBarTintColor = UIColor(red: 0.1254901961, green: 0.3490196078, blue: 0.5843137255, alpha: 1.0)
        }
        else{
            UIApplication.shared.statusBarStyle = .default
        }
        self.present(svc, animated: true, completion: nil)
    }
    @IBOutlet weak var prevButton: UIBarButtonItem!
    @IBAction func prevButton(_ sender: UIBarButtonItem) {
        UniversalMethods.prevMealToLabel(dateLabel: self.dateLabel, prevButton: self.prevButton, nextButton: self.nextButton, defaults: self.defaults, fetchData: self.fetchData, mealLabel: self.mealLabel, mealTitleLabel: self.mealTitleLabel, navigationItem: self.navigationItem, subView: self.subView, tableView: self.tableView, refreshControl: self.refreshControl, loadWheel: self.loadWheel, mealType: mealType)
    }
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBAction func nextButton(_ sender: UIBarButtonItem) {
        UniversalMethods.nextMealToLabel(dateLabel: self.dateLabel, prevButton: self.prevButton, nextButton: self.nextButton, defaults: self.defaults, fetchData: self.fetchData, mealLabel: self.mealLabel, mealTitleLabel: self.mealTitleLabel, navigationItem: self.navigationItem, refreshControl: self.refreshControl, loadWheel: self.loadWheel, subView: self.subView, tableView: self.tableView, mealType: mealType)
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadWheel: UIActivityIndicatorView!
    
    var fetchData:FetchData = FetchData()
    var defaults:UserDefaults = UserDefaults(suiteName: "group.grabberData")!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    let url = URL(string: "http://www.sagedining.com/menus/mercersburgacademy")
    var mealType = FetchData.MealType.LUNCH
    
    override func viewDidLoad() {
        if !defaults.bool(forKey: "NonDefaultSettings"){
            defaults.set(true, forKey: "LunchNotifOn")
            defaults.set(true, forKey: "DinnerNotifOn")
            defaults.set(9, forKey: "LunchNotifHour")
            defaults.set(55, forKey: "LunchNotifMin")
            defaults.set(16, forKey: "DinnerNotifHour")
            defaults.set(00, forKey: "DinnerNotifMin")
            defaults.set(true, forKey: "NonDefaultSettings")
        }
        self.refreshControl.addTarget(self, action: #selector(ViewControllerL.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        mealTitleLabel.isHidden = true
        mealLabel.isHidden = true
        dateLabel.isHidden = true
        UniversalMethods.loadDataVC(fetchData: &fetchData, prevButton: prevButton, nextButton: nextButton, defaults: defaults, dateLabel: dateLabel, navigationItem: navigationItem, mealTitleLabel: mealTitleLabel, mealLabel: mealLabel, loadWheel: loadWheel, refreshControl: refreshControl, subView: subView, tableView: tableView, mealType: mealType)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UniversalMethods.loadDataVC(fetchData: &fetchData, prevButton: prevButton, nextButton: nextButton, defaults: defaults, dateLabel: dateLabel, navigationItem: navigationItem, mealTitleLabel: mealTitleLabel, mealLabel: mealLabel, loadWheel: loadWheel, refreshControl: refreshControl, subView: subView, tableView: tableView, mealType: mealType)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func refresh(sender: AnyObject) {
        UniversalMethods.refreshAction(defaults: defaults, fetchData: &fetchData, prevButton: prevButton, nextButton: nextButton, dateLabel: dateLabel, navigationItem: navigationItem, mealTitleLabel: mealTitleLabel, mealLabel: mealLabel, loadWheel: loadWheel, refreshControl: refreshControl, subView: subView, tableView: tableView, mealType: mealType)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
} 
