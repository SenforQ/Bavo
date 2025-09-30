
//: Declare String Begin

/*: "Net Error, Try again later" :*/
fileprivate let dataCoordinateShow_:String = "Net Errorbasic via against"
fileprivate let app_computerConst_:[Character] = [","," ","T","r","y"," ","a","g","a","i","n"," ","l","a","t","e","r"]

/*: "data" :*/
fileprivate let show_freezeUser_:[Character] = ["d","a","t","a"]

/*: ":null" :*/
fileprivate let user_blackApp:String = ":nullthat model"

/*: "json error" :*/
fileprivate let noti_poorApp:[Character] = ["j","s","o","n"," ","e","r","r","o"]
fileprivate let app_passingConst_:String = "inherit"

/*: "platform=iphone&version= :*/
fileprivate let showNameComponentData:[Character] = ["p","l","a","t","f","o","r","m"]
fileprivate let kAppNoti_:String = "arrow re count=iphon"
fileprivate let main_theShow_:String = "e&vercurrent manager production"

/*: &packageId= :*/
fileprivate let dataReduceApp:[Character] = ["&","p","a","c","k","a","g","e","I","d","="]

/*: &bundleId= :*/
fileprivate let constDoingK:String = "&bwarn launch manager"
fileprivate let app_remoteFair:String = "undframe"

/*: &lang= :*/
fileprivate let main_writingShow_:String = "&lang=ok above"

/*: ; build: :*/
fileprivate let kFilterShow:String = "; build:count constant"

/*: ; iOS  :*/
fileprivate let notiConstantShow:String = ";"
fileprivate let showFeedbackData_:String = "home format product iOS "

//: Declare String End

//: import Alamofire
import Alamofire
//: import CoreMedia
import CoreMedia
//: import HandyJSON
import HandyJSON
// __DEBUG__
// __CLOSE_PRINT__
//: import UIKit
import UIKit

//: typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: AppErrorResponse?) -> Void
typealias FinishBlock = (_ succeed: Bool, _ result: Any?, _ errorModel: MotherErrorResponse?) -> Void

//: @objc class AppRequestTool: NSObject {
@objc class CognitionRequestTool: NSObject {
    /// 发起Post请求
    /// - Parameters:
    ///   - model: 请求参数
    ///   - completion: 回调
    //: class func startPostRequest(model: AppRequestModel, completion: @escaping FinishBlock) {
    class func exclusiveGoing(model: RegulateRequestModel, completion: @escaping FinishBlock) {
        //: let serverUrl = self.buildServerUrl(model: model)
        let serverUrl = self.extendInherit(model: model)
        //: let headers = self.getRequestHeader(model: model)
        let headers = self.via(model: model)
        //: AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
        AF.request(serverUrl, method: .post, parameters: model.params, headers: headers, requestModifier: { $0.timeoutInterval = 10.0 }).responseData { [self] responseData in
            //: switch responseData.result {
            switch responseData.result {
            //: case .success:
            case .success:
                //: func__requestSucess(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)
                assemblage(model: model, response: responseData.response!, responseData: responseData.data!, completion: completion)

            //: case .failure:
            case .failure:
                //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "Net Error, Try again later"))
                completion(false, nil, MotherErrorResponse(errorCode: TempTitleConvertible.NetError.rawValue, errorMsg: (String(dataCoordinateShow_.prefix(9)) + String(app_computerConst_))))
            }
        }
    }

    //: class func func__requestSucess(model: AppRequestModel, response: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
    class func assemblage(model _: RegulateRequestModel, response _: HTTPURLResponse, responseData: Data, completion: @escaping FinishBlock) {
        //: var responseJson = String(data: responseData, encoding: .utf8)
        var responseJson = String(data: responseData, encoding: .utf8)
        //: responseJson = responseJson?.replacingOccurrences(of: "\"data\":null", with: "\"data\":{}")
        responseJson = responseJson?.replacingOccurrences(of: "\"" + (String(show_freezeUser_)) + "\"" + (String(user_blackApp.prefix(5))), with: "" + "\"" + (String(show_freezeUser_)) + "\"" + ":{}")
        //: if let responseModel = JSONDeserializer<AppBaseResponse>.deserializeFrom(json: responseJson) {
        if let responseModel = JSONDeserializer<ShapeModelType>.deserializeFrom(json: responseJson) {
            //: if responseModel.errno == RequestResultCode.Normal.rawValue {
            if responseModel.errno == TempTitleConvertible.Normal.rawValue {
                //: completion(true, responseModel.data, nil)
                completion(true, responseModel.data, nil)
                //: } else {
            } else {
                //: completion(false, responseModel.data, AppErrorResponse.init(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                completion(false, responseModel.data, MotherErrorResponse(errorCode: responseModel.errno, errorMsg: responseModel.msg ?? ""))
                //: switch responseModel.errno {
                switch responseModel.errno {
//                case TempTitleConvertible.NeedReLogin.rawValue:
//                    NotificationCenter.default.post(name: DID_LOGIN_OUT_SUCCESS_NOTIFICATION, object: nil, userInfo: nil)
                //: default:
                default:
                    //: break
                    break
                }
            }
            //: } else {
        } else {
            //: completion(false, nil, AppErrorResponse.init(errorCode: RequestResultCode.NetError.rawValue, errorMsg: "json error"))
            completion(false, nil, MotherErrorResponse(errorCode: TempTitleConvertible.NetError.rawValue, errorMsg: (String(noti_poorApp) + app_passingConst_.replacingOccurrences(of: "inherit", with: "r"))))
        }
    }

    //: class func buildServerUrl(model: AppRequestModel) -> String {
    class func extendInherit(model: RegulateRequestModel) -> String {
        //: var serverUrl: String = model.requestServer
        var serverUrl: String = model.requestServer
        //: let otherParams = "platform=iphone&version=\(AppNetVersion)&packageId=\(PackageID)&bundleId=\(AppBundle)&lang=\(UIDevice.interfaceLang)"
        let otherParams = (String(showNameComponentData) + String(kAppNoti_.suffix(6)) + String(main_theShow_.prefix(5)) + "sion=") + "\(userTheData)" + (String(dataReduceApp)) + "\(mainKeyNoti_)" + (String(constDoingK.prefix(2)) + app_remoteFair.replacingOccurrences(of: "frame", with: "l") + "eId=") + "\(user_numberApp)" + (String(main_writingShow_.prefix(6))) + "\(UIDevice.interfaceLang)"
        //: if !model.requestPath.isEmpty {
        if !model.requestPath.isEmpty {
            //: serverUrl.append("/\(model.requestPath)")
            serverUrl.append("/\(model.requestPath)")
        }
        //: serverUrl.append("?\(otherParams)")
        serverUrl.append("?\(otherParams)")

        //: return serverUrl
        return serverUrl
    }

    /// 获取请求头参数
    /// - Parameter model: 请求模型
    /// - Returns: 请求头参数
    //: class func getRequestHeader(model: AppRequestModel) -> HTTPHeaders {
    class func via(model _: RegulateRequestModel) -> HTTPHeaders {
        //: let userAgent = "\(AppName)/\(AppVersion) (\(AppBundle); build:\(AppBuildNumber); iOS \(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        let userAgent = "\(noti_cornerIndexReceiverShow_)/\(constPastData) (\(user_numberApp)" + (String(kFilterShow.prefix(8))) + "\(show_receiverMaxData_)" + (notiConstantShow.capitalized + String(showFeedbackData_.suffix(5))) + "\(UIDevice.current.systemVersion); \(UIDevice.modelName))"
        //: let headers = [HTTPHeader.userAgent(userAgent)]
        let headers = [HTTPHeader.userAgent(userAgent)]
        //: return HTTPHeaders(headers)
        return HTTPHeaders(headers)
    }
}
