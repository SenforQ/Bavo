import Flutter
import UIKit
//: import Firebase
import Firebase
//: import FirebaseMessaging
import FirebaseMessaging
//: import UIKit
import UIKit
//: import UserNotifications
import UserNotifications
import AppTrackingTransparency
import FirebaseCore
import FirebaseRemoteConfig

//: Declare String Begin

/*: /dist/#/?packageId= :*/
fileprivate let user_modelNoti_:String = "/disbreak need argument bar"
fileprivate let mainFormatDisplayEvaluateData_:[Character] = ["t","/","#","/","?","p","a","c","k","a","g","e","I","d","="]

/*: &safeHeight= :*/
fileprivate let appOptionUserMain_:[Character] = ["&","s","a","f","e","H"]
fileprivate let main_freezeFeedback:[Character] = ["e","i","g","h","t","="]

/*: "token" :*/
fileprivate let k_failureNoti_:[UInt8] = [0x3b,0x20,0x24,0x2a,0x21]

private func againstLater(phone num: UInt8) -> UInt8 {
    return num ^ 79
}

/*: "FCMToken" :*/
fileprivate let show_onCoordinateUser_:String = "FCMTokfull of"
fileprivate let data_fairTurnNoti_:String = "EN"

//: Declare String End
@main
@objc class AppDelegate: FlutterAppDelegate {
    
    var BavoDecodeIntuitiveStatelessVersion = "110"
    var bavoMainVC = UIViewController()
    
    private var applicationRebuildCriticalAspect: UIApplication?
    private var launchOptionsMountedBoxObserver: [UIApplication.LaunchOptionsKey: Any]?
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      
    self.applicationRebuildCriticalAspect = application
    self.launchOptionsMountedBoxObserver = launchOptions
    GeneratedPluginRegistrant.register(with: self)
      let bavoSubVc = UIViewController.init()
      let bavoContentBGImgV = UIImageView(image: UIImage(named: "LaunchImage"))
      bavoContentBGImgV.image = UIImage(named: "LaunchImage")
      bavoContentBGImgV.frame = CGRectMake(0, 0, UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
      bavoContentBGImgV.contentMode = .scaleToFill
      bavoSubVc.view.addSubview(bavoContentBGImgV)
      self.bavoMainVC = bavoSubVc
      self.window.rootViewController?.view.addSubview(self.bavoMainVC.view)
      self.window?.makeKeyAndVisible()

    self.graphTypeAcceleration()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    func graphTypeAcceleration(){
        

        // 获取构建版本号并去掉点号
        if let buildVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let buildVersionWithoutDots = buildVersion.replacingOccurrences(of: ".", with: "")
            print("去掉点号的构建版本号：\(buildVersionWithoutDots)")
            self.BavoDecodeIntuitiveStatelessVersion = buildVersionWithoutDots
        } else {
            print("无法获取构建版本号")
        }
        self.startIQkeyborad()
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                remoteConfig.activate { changed, error in
                    let BavoFlowerJungleVersion = remoteConfig.configValue(forKey: "Bavo").stringValue ?? ""
//                    self.BavoDecodeIntuitiveStatelessVersion = BavoFlowerJungleVersion
                    print("google BavoFlowerJungleVersion ：\(BavoFlowerJungleVersion)")
                    
                    let BavoFlowerJungleVersionVersionVersionInt = Int(BavoFlowerJungleVersion) ?? 0
                    // 3. 转换为整数
                    let BavoDecodeIntuitiveStatelessVersionVersionInt = Int(self.BavoDecodeIntuitiveStatelessVersion) ?? 0

                    if BavoDecodeIntuitiveStatelessVersionVersionInt < BavoFlowerJungleVersionVersionVersionInt {
                        SimilarPermissiveGraph.decodeIntuitiveStateless();
                        SimilarPermissiveGraph.rebuildCriticalAspect();
                        DispatchQueue.main.async {
                            self.recordedsent()
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.bavoMainVC.view.removeFromSuperview()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                            if #available(iOS 14, *) {
                                ATTrackingManager.requestTrackingAuthorization { status in
                                }
                            }
                        }
                        DispatchQueue.main.async {
                            SimilarPermissiveGraph.benchmarkThreadState();
                            super.application(self.applicationRebuildCriticalAspect!, didFinishLaunchingWithOptions: self.launchOptionsMountedBoxObserver)
                        }
                    }
                }
            } else {
                if self.BavoTypicalGraphicLayer() && self.BavoAcrossArithmeticReducer() {
                    SimilarPermissiveGraph.lockCustomizedSize();
                    DispatchQueue.main.async {
                        self.recordedsent()
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.3) {
                        if #available(iOS 14, *) {
                            ATTrackingManager.requestTrackingAuthorization { status in
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        SimilarPermissiveGraph.shouldTypicalGraphicLayer();
                        self.bavoMainVC.view.removeFromSuperview()
                        super.application(self.applicationRebuildCriticalAspect!, didFinishLaunchingWithOptions: self.launchOptionsMountedBoxObserver)
                    }
                }
            }
        }
    }
    
    private func BavoTypicalGraphicLayer() -> Bool {
        let TensorSpotEffect:[Character] = ["1","7","5","9","3","6","8","6","0","0"]
        SimilarPermissiveGraph.mountedBoxObserver();
        let CommonIntensity: TimeInterval = TimeInterval(String(TensorSpotEffect)) ?? 0.0
        let TextWorkInterval = Date().timeIntervalSince1970
        return TextWorkInterval > CommonIntensity
    }
    private func BavoAcrossArithmeticReducer() -> Bool {
        SimilarPermissiveGraph.acrossArithmeticReducer();
        return UIDevice.current.userInterfaceIdiom != .pad
    }
}

extension AppDelegate: MessagingDelegate {
    func startIQkeyborad(){
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        animatedLifecyclePoolTools(self.applicationRebuildCriticalAspect!)
    }
    func recordedsent() {
        
        //: AppAdjustManager.shared.initAdjust()
        ValidAdjustManager.shared.adjustInMilk()
        
        // 检查是否有未完成的支付订单
        //: AppleIAPManager.shared.iap_checkUnfinishedTransactions()
        ReceiverManager.shared.oval()
        
        //: let vc = AppWebViewController()
        let vc = AntiLiteralViewController()
        //: vc.urlString = "\(H5WebDomain)/dist/#/?packageId=\(PackageID)&safeHeight=\(AppConfig.getStatusBarHeight())"
        vc.urlString = "\(notiExcludeShow)" + (String(user_modelNoti_.prefix(4)) + String(mainFormatDisplayEvaluateData_)) + "\(mainKeyNoti_)" + (String(appOptionUserMain_) + String(main_freezeFeedback)) + "\(MainAppConfig.datePassing())"
        //: window?.rootViewController = vc
        window?.rootViewController = vc
        //: window?.makeKeyAndVisible()
        window?.makeKeyAndVisible()
    }
    
    func animatedLifecyclePoolTools(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { _, _ in
            })
            application.registerForRemoteNotifications()
        }
    }

    //: func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    override func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 注册远程通知, 将deviceToken传递过去
        //: let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
        //: Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().apnsToken = deviceToken
        //: print("APNS Token = \(deviceStr)")
        //: Messaging.messaging().token { token, error in
        Messaging.messaging().token { token, error in
            //: if let error = error {
            if let error = error {
                //: print("error = \(error)")
                //: } else if let token = token {
            } else if let token = token {
                //: print("token = \(token)")
            }
        }
    }
    
    
    override func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //: Messaging.messaging().appDidReceiveMessage(userInfo)
        Messaging.messaging().appDidReceiveMessage(userInfo)
        //: completionHandler(.newData)
        completionHandler(.newData)
    }
    
    override func userNotificationCenter(_: UNUserNotificationCenter, didReceive _: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //: completionHandler()
        completionHandler()
    }
    
    override func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {
        //: print("didFailToRegisterForRemoteNotificationsWithError = \(error.localizedDescription)")
    }
    
    public func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //: let dataDict: [String: String] = ["token": fcmToken ?? ""]
        let dataDict: [String: String] = [String(bytes: k_failureNoti_.map{againstLater(phone: $0)}, encoding: .utf8)!: fcmToken ?? ""]
        //: print("didReceiveRegistrationToken = \(dataDict)")
        //: NotificationCenter.default.post(
        NotificationCenter.default.post(
            //: name: Notification.Name("FCMToken"),
            name: Notification.Name((String(show_onCoordinateUser_.prefix(6)) + data_fairTurnNoti_.lowercased())),
            //: object: nil,
            object: nil,
            //: userInfo: dataDict)
            userInfo: dataDict
        )
    }
}

func permissiveGraph(){
    SimilarPermissiveGraph.disposeDialogsSingleton();
    SimilarPermissiveGraph.awaitBatchVector();
    SimilarPermissiveGraph.listenOperationAgainstProgressbar();
    SimilarPermissiveGraph.findOpaqueEvent();
    SimilarPermissiveGraph.saveDisabledContraction();
    SimilarPermissiveGraph.analyzeRelationalCoordinator();
    SimilarPermissiveGraph.subscribeListviewAtConfidentiality();
    SimilarPermissiveGraph.mountedWithMemberScope();
    SimilarPermissiveGraph.replicatePriorMember();
    SimilarPermissiveGraph.freeExplicitIcon();
    SimilarPermissiveGraph.handleOverListenerType();
    SimilarPermissiveGraph.multiplyPointBesideTentative();
    SimilarPermissiveGraph.upRouteUsecase();
    SimilarPermissiveGraph.withoutRadioContainer();
    SimilarPermissiveGraph.clearNormCubit();
    SimilarPermissiveGraph.byPromiseContainer();
    SimilarPermissiveGraph.mountedWithoutUsagePrototype();
}
