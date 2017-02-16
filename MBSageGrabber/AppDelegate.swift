//
//  AppDelegate.swift
//  MBSageGrabber
//
//  Created by Kent Hall on 9/14/16.
//  Copyright © 2016 kentahallis. All rights reserved.
//

import UIKit
import SystemConfiguration
import PushKit
//import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate/*, WCSessionDelegate*/ {

    let APP_ID = "6099AD44-61F3-001C-FF14-5D491AF13E00"
    let SECRET_KEY = "BF19D87F-736D-EFE8-FFF8-F5925541C500"
    let VERSION_NUM = "v1"
    
    var backendless = Backendless.sharedInstance()
    let user: BackendlessUser = BackendlessUser()
    
    var window: UIWindow?
    var fetchData:FetchData = FetchData()
    var defaults = UserDefaults(suiteName: "group.grabberData")
    //let wcsession = WCSession.default()

    func registerVoipNotifications(application:UIApplication) {
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.desiredPushTypes = NSSet(object: PKPushType.voIP) as? Set<PKPushType>
        voipRegistry.delegate = self
        NSLog("VoIP registered")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if (connectedToNetwork()){
            registerVoipNotifications(application: application)
            application.registerForRemoteNotifications()
            
            let types: UIUserNotificationType = [UIUserNotificationType.sound, UIUserNotificationType.alert]
            let notificationSettings = UIUserNotificationSettings(types: types, categories: nil)
            application.registerUserNotificationSettings(notificationSettings)

            backendless?.initApp(APP_ID, secret:SECRET_KEY, version:VERSION_NUM)
        }
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        NSLog("app launched")
        
//        if WCSession.isSupported() {
//            wcsession.delegate = self
//            wcsession.activate()
//        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        defaults?.mutableSetValue(forKey: "Day")
        defaults?.mutableSetValue(forKey: "Month")
        defaults?.mutableSetValue(forKey: "Date")
        defaults?.mutableSetValue(forKey: "navItemPromptU")
        defaults?.mutableSetValue(forKey: "Breakfast")
        for i in 1...7{
            defaults?.mutableSetValue(forKey: "Breakfast\(i)")
        }
        defaults?.mutableSetValue(forKey: "Lunch")
        for i in 1...7{
            defaults?.mutableSetValue(forKey: "Lunch\(i)")
        }
        defaults?.mutableSetValue(forKey: "Dinner")
        for i in 1...7{
            defaults?.mutableSetValue(forKey: "Dinner\(i)")
        }
        defaults?.mutableSetValue(forKey: "Nondefaults?ettings")
        defaults?.mutableSetValue(forKey: "LunchNotifOn")
        defaults?.mutableSetValue(forKey: "DinnerNotifOn")
        defaults?.mutableSetValue(forKey: "LunchNotifHour")
        defaults?.mutableSetValue(forKey: "LunchNotifMin")
        defaults?.mutableSetValue(forKey: "DinnerNotifHour")
        defaults?.mutableSetValue(forKey: "DinnerNotifMin")
        //for location in prevButton and nextButton of UI
        defaults?.mutableSetValue(forKey: "DaysForward")
        //for days ahead with notifications
        defaults?.mutableSetValue(forKey: "DaysFurtherFuture")
        defaults?.mutableSetValue(forKey: "ShowingTomorrow")
        defaults?.mutableSetValue(forKey: "WebRefreshedToday")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        NSLog("app terminated")
        defaults?.set(0, forKey: "DaysForward")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
        backgroundRefresh()
        NSLog("push received")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if (connectedToNetwork()){
            DispatchQueue.global(qos: .background).async {
//                if ((try? self.backendless?.messaging.registerDeviceToken(deviceToken)) != nil){
//                    try? self.backendless?.messaging.registerDevice()
//                    NSLog("token registered")
//                }
                try? self.backendless?.messaging.registerDeviceToken(deviceToken)
            }
        }
    }
    
    func application(_ application: UIApplication,
                              performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        completionHandler(UIBackgroundFetchResult.newData)
        backgroundRefresh()
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let tabBar = self.window?.rootViewController as! UITabBarController
        switch shortcutItem.type{
            case "qActionB":
                tabBar.selectedIndex=0
                break;
            case "qActionL":
                tabBar.selectedIndex=1
                break;
            case "qActionD":
                tabBar.selectedIndex=2
                break;
            default:
                break;
        }
    }
    
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
//        replyHandler(["Breakfast":defaults?.string(forKey: "Breakfast"), "Lunch":defaults?.string(forKey: "Lunch") as Any, "Dinner":defaults?.string(forKey: "Dinner") as Any])
//    }
//    
//    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
//    @available(iOS 9.3, *)
//    public func sessionDidBecomeInactive(_ session: WCSession) {}
//    
//    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
//    @available(iOS 9.3, *)
//    public func sessionDidDeactivate(_ session: WCSession) {}
//    
//    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
//    @available(iOS 9.3, *)
//    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        //        if (connectedToNetwork()){
        //            DispatchQueue.global(qos: .background).async {
        //                if ((try? self.backendless?.messaging.registerDevice()) != nil){
        //                    self.backendless?.messaging.registerDeviceToken(credentials.token)
        //                    NSLog("token registered")
        //                }
        //            }
        //        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
        backgroundRefresh()
        NSLog("push received")
    }
    
    func backgroundRefresh() {
        fetchData = FetchData()
        if (self.fetchData.defaults.integer(forKey: "Day") != NSCalendar.current.component(Calendar.Component.day, from: Date())){
            if connectedToNetwork(){
                self.fetchData.initLoad()
                NSLog("fetching data")
            }
//            let tempDate = UniversalMethods.dateFromDefaults(defaults: defaults!)
//            let daysFurther = NSCalendar.current.dateComponents([Calendar.Component.day], from: tempDate, to: Date()).day!
//            if (defaults?.integer(forKey: "DaysFurtherFuture") != daysFurther){
//                if (defaults?.string(forKey: "Lunch") != nil){
//                    if #available(iOS 10.0, *) {
//                        if (!UniversalMethods.lunchNotifPassed(defaults: self.defaults!) && self.defaults!.string(forKey: "Lunch") != FetchData().noMealString) {
//                            UniversalMethods.addUNNotif(hour: self.defaults!.integer(forKey: "LunchNotifHour"), minute: self.defaults!.integer(forKey: "LunchNotifMin"), text: self.defaults!.string(forKey: "Lunch")!.components(separatedBy: "<")[0], title: "Lunch Today", id: "lunch", noMealString: FetchData().noMealString)
//                        }
//                    }
//                }
//                if (defaults?.string(forKey: "Dinner") != nil){
//                    //do same as above for dinner
//                    if #available(iOS 10.0, *) {
//                        if (!UniversalMethods.dinnerNotifPassed(defaults: self.defaults!) && self.defaults!.string(forKey: "Dinner") != FetchData().noMealString) {
//                            UniversalMethods.addUNNotif(hour: self.defaults!.integer(forKey: "DinnerNotifHour"), minute: self.defaults!.integer(forKey: "DinnerNotifMin"), text: self.defaults!.string(forKey: "Dinner")!.components(separatedBy: "<")[0], title: "Dinner Today", id: "dinner", noMealString: FetchData().noMealString)
//                        }
//                    }
//                }
                //NSLog("daysFurther: \(daysFurther)")
                //defaults?.set(daysFurther, forKey: "DaysFurtherFuture")
                //NSLog("future meal notif added")
            //}
        }

    }
    
    func connectedToNetwork() -> Bool {
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

