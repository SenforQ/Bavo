
//: Declare String Begin

/*: "linknoop" :*/
fileprivate let main_bodyRemoveData:[Character] = ["l","i","n","k","n","o","o","p"]

/*: "http://m. :*/
fileprivate let main_agentApp:[Character] = ["h","t","t","p",":","/","/","m","."]

/*: .com" :*/
fileprivate let show_degreeNoti:[Character] = [".","c","o","m"]

/*: "1.9.1" :*/
fileprivate let notiErrorUser_:[Character] = ["1",".","9",".","1"]

/*: "998" :*/
fileprivate let noti_postCornerEffectUser:String = "998"

/*: "1cy0vyvterxc" :*/
fileprivate let k_originShow:String = "1cy0boundary display normal"
fileprivate let main_viewShow:String = "inheritc"

/*: "3lek1z" :*/
fileprivate let app_scriptRemove:[Character] = ["3","l","e","k","1","z"]

/*: "CFBundleShortVersionString" :*/
fileprivate let data_styleConst_:[Character] = ["C","F","B","u","n","d","l","e","S","h","o","r","t","V"]
fileprivate let dataTheUser:String = "eritemion"

/*: "CFBundleDisplayName" :*/
fileprivate let kAllMain:[Character] = ["C","F","B","u","n","d","l","e","D","i","s","p","l","a","y","N"]
fileprivate let noti_systemRemoveUser:String = "aload"

/*: "CFBundleVersion" :*/
fileprivate let noti_productionShow:String = "CFBulabel phone reduce freeze"
fileprivate let appVersionUser_:String = "erswhiten"

/*: "weixin" :*/
fileprivate let user_homeKindShow:[Character] = ["w","e","i","x","i","n"]

/*: "wxwork" :*/
fileprivate let mainTeamLayer:String = "wxwcontactrk"

/*: "dingtalk" :*/
fileprivate let showOptionConst_:[Character] = ["d","i","n","g","t","a","l","k"]

/*: "lark" :*/
fileprivate let constCollectionFireShow_:[Character] = ["l","a","r","k"]

//: Declare String End

// __DEBUG__
// __CLOSE_PRINT__
//
//  MainAppConfig.swift
//  OverseaH5
//
//  Created by young on 2025/9/24.
//

//: import KeychainSwift
import KeychainSwift
//: import UIKit
import UIKit

/// 域名
//: let ReplaceUrlDomain = "linknoop"
let app_livingUser_ = (String(main_bodyRemoveData))
//: let H5WebDomain = "http://m.\(ReplaceUrlDomain).com"
let notiExcludeShow = (String(main_agentApp)) + "\(app_livingUser_)" + (String(show_degreeNoti))
/// 网络版本号
//: let AppNetVersion = "1.9.1"
let userTheData = (String(notiErrorUser_))
/// 包ID
//: let PackageID = "998"
let mainKeyNoti_ = (noti_postCornerEffectUser.capitalized)
/// Adjust
//: let AdjustKey = "1cy0vyvterxc"
let noti_viewMain = "zh87g37xy9z4"
//: let AdInstallToken = "3lek1z"
let userTriggerBoundNoti = "x34yed"

//: let AppVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let constPastData = Bundle.main.infoDictionary![(String(data_styleConst_) + dataTheUser.replacingOccurrences(of: "item", with: "s") + "String")] as! String
//: let AppBundle = Bundle.main.bundleIdentifier!
let user_numberApp = Bundle.main.bundleIdentifier!
//: let AppName = Bundle.main.infoDictionary!["CFBundleDisplayName"] ?? ""
let noti_cornerIndexReceiverShow_ = Bundle.main.infoDictionary![(String(kAllMain) + noti_systemRemoveUser.replacingOccurrences(of: "load", with: "me"))] ?? ""
//: let AppBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
let show_receiverMaxData_ = Bundle.main.infoDictionary![(String(noti_productionShow.prefix(4)) + "ndleV" + appVersionUser_.replacingOccurrences(of: "white", with: "io"))] as! String

//: class AppConfig: NSObject {
class MainAppConfig: NSObject {
    /// 获取状态栏高度
    //: class func getStatusBarHeight() -> CGFloat {
    class func datePassing() -> CGFloat {
        //: if #available(iOS 13.0, *) {
        if #available(iOS 13.0, *) {
            //: if let statusBarManager = UIApplication.shared.windows.first?
            if let statusBarManager = UIApplication.shared.windows.first?
                //: .windowScene?.statusBarManager
                .windowScene?.statusBarManager
            {
                //: return statusBarManager.statusBarFrame.size.height
                return statusBarManager.statusBarFrame.size.height
            }
            //: } else {
        } else {
            //: return UIApplication.shared.statusBarFrame.size.height
            return UIApplication.shared.statusBarFrame.size.height
        }
        //: return 20.0
        return 20.0
    }

    /// 获取window
    //: class func getWindow() -> UIWindow {
    class func constant() -> UIWindow {
        //: var window = UIApplication.shared.windows.first(where: {
        var window = UIApplication.shared.windows.first(where: {
            //: $0.isKeyWindow
            $0.isKeyWindow
            //: })
        })
        // 是否为当前显示的window
        //: if window?.windowLevel != UIWindow.Level.normal {
        if window?.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: return window!
        return window!
    }

    /// 获取当前控制器
    //: class func currentViewController() -> (UIViewController?) {
    class func basic() -> (UIViewController?) {
        //: var window = AppConfig.getWindow()
        var window = MainAppConfig.constant()
        //: if window.windowLevel != UIWindow.Level.normal {
        if window.windowLevel != UIWindow.Level.normal {
            //: let windows = UIApplication.shared.windows
            let windows = UIApplication.shared.windows
            //: for windowTemp in windows {
            for windowTemp in windows {
                //: if windowTemp.windowLevel == UIWindow.Level.normal {
                if windowTemp.windowLevel == UIWindow.Level.normal {
                    //: window = windowTemp
                    window = windowTemp
                    //: break
                    break
                }
            }
        }
        //: let vc = window.rootViewController
        let vc = window.rootViewController
        //: return currentViewController(vc)
        return supra(vc)
    }

    //: class func currentViewController(_ vc: UIViewController?)
    class func supra(_ vc: UIViewController?)
        //: -> UIViewController?
        -> UIViewController?
    {
        //: if vc == nil {
        if vc == nil {
            //: return nil
            return nil
        }
        //: if let presentVC = vc?.presentedViewController {
        if let presentVC = vc?.presentedViewController {
            //: return currentViewController(presentVC)
            return supra(presentVC)
            //: } else if let tabVC = vc as? UITabBarController {
        } else if let tabVC = vc as? UITabBarController {
            //: if let selectVC = tabVC.selectedViewController {
            if let selectVC = tabVC.selectedViewController {
                //: return currentViewController(selectVC)
                return supra(selectVC)
            }
            //: return nil
            return nil
            //: } else if let naiVC = vc as? UINavigationController {
        } else if let naiVC = vc as? UINavigationController {
            //: return currentViewController(naiVC.visibleViewController)
            return supra(naiVC.visibleViewController)
            //: } else {
        } else {
            //: return vc
            return vc
        }
    }
}

// MARK: - Device

//: extension UIDevice {
extension UIDevice {
    //: static var modelName: String {
    static var modelName: String {
        //: var systemInfo = utsname()
        var systemInfo = utsname()
        //: uname(&systemInfo)
        uname(&systemInfo)
        //: let machineMirror = Mirror(reflecting: systemInfo.machine)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        //: let identifier = machineMirror.children.reduce("") {
        let identifier = machineMirror.children.reduce("") {
            //: identifier, element in
            identifier, element in
            //: guard let value = element.value as? Int8, value != 0 else {
            guard let value = element.value as? Int8, value != 0 else {
                //: return identifier
                return identifier
            }
            //: return identifier + String(UnicodeScalar(UInt8(value)))
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        //: return identifier
        return identifier
    }

    /// 获取当前系统时区
    //: static var timeZone: String {
    static var timeZone: String {
        //: let currentTimeZone = NSTimeZone.system
        let currentTimeZone = NSTimeZone.system
        //: return currentTimeZone.identifier
        return currentTimeZone.identifier
    }

    /// 获取当前系统语言
    //: static var langCode: String {
    static var langCode: String {
        //: let language = Locale.preferredLanguages.first
        let language = Locale.preferredLanguages.first
        //: return language ?? ""
        return language ?? ""
    }

    /// 获取接口语言
    //: static var interfaceLang: String {
    static var interfaceLang: String {
        //: let lang = UIDevice.getSystemLangCode()
        let lang = UIDevice.quantityroduce()
        //: if ["en", "ar", "es", "pt"].contains(lang) {
        if ["en", "ar", "es", "pt"].contains(lang) {
            //: return lang
            return lang
        }
        //: return "en"
        return "en"
    }

    /// 获取当前系统地区
    //: static var countryCode: String {
    static var countryCode: String {
        //: let locale = Locale.current
        let locale = Locale.current
        //: let countryCode = locale.regionCode
        let countryCode = locale.regionCode
        //: return countryCode ?? ""
        return countryCode ?? ""
    }

    /// 获取系统UUID（每次调用都会产生新值，所以需要keychain）
    //: static var systemUUID: String {
    static var systemUUID: String {
        //: let key = KeychainSwift()
        let key = KeychainSwift()
        //: if let value = key.get(AdjustKey) {
        if let value = key.get(noti_viewMain) {
            //: return value
            return value
            //: } else {
        } else {
            //: let value = NSUUID().uuidString
            let value = NSUUID().uuidString
            //: key.set(value, forKey: AdjustKey)
            key.set(value, forKey: noti_viewMain)
            //: return value
            return value
        }
    }

    /// 获取已安装应用信息
    //: static var getInstalledApps: String {
    static var getInstalledApps: String {
        //: var appsArr: [String] = []
        var appsArr: [String] = []
        //: if UIDevice.canOpenApp("weixin") {
        if UIDevice.always((String(user_homeKindShow))) {
            //: appsArr.append("weixin")
            appsArr.append((String(user_homeKindShow)))
        }
        //: if UIDevice.canOpenApp("wxwork") {
        if UIDevice.always((mainTeamLayer.replacingOccurrences(of: "contact", with: "o"))) {
            //: appsArr.append("wxwork")
            appsArr.append((mainTeamLayer.replacingOccurrences(of: "contact", with: "o")))
        }
        //: if UIDevice.canOpenApp("dingtalk") {
        if UIDevice.always((String(showOptionConst_))) {
            //: appsArr.append("dingtalk")
            appsArr.append((String(showOptionConst_)))
        }
        //: if UIDevice.canOpenApp("lark") {
        if UIDevice.always((String(constCollectionFireShow_))) {
            //: appsArr.append("lark")
            appsArr.append((String(constCollectionFireShow_)))
        }
        //: if appsArr.count > 0 {
        if appsArr.count > 0 {
            //: return appsArr.joined(separator: ",")
            return appsArr.joined(separator: ",")
        }
        //: return ""
        return ""
    }

    /// 判断是否安装app
    //: static func canOpenApp(_ scheme: String) -> Bool {
    static func always(_ scheme: String) -> Bool {
        //: let url = URL(string: "\(scheme)://")!
        let url = URL(string: "\(scheme)://")!
        //: if UIApplication.shared.canOpenURL(url) {
        if UIApplication.shared.canOpenURL(url) {
            //: return true
            return true
        }
        //: return false
        return false
    }

    /// 获取系统语言
    /// - Returns: 国际通用语言Code
    //: @objc public class func getSystemLangCode() -> String {
    @objc public class func quantityroduce() -> String {
        //: let language = NSLocale.preferredLanguages.first
        let language = NSLocale.preferredLanguages.first
        //: let array = language?.components(separatedBy: "-")
        let array = language?.components(separatedBy: "-")
        //: return array?.first ?? "en"
        return array?.first ?? "en"
    }
}
