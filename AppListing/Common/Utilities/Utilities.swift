
import UIKit
import Alamofire
import Foundation
import SystemConfiguration
import UserNotifications
import Kingfisher
import AVFoundation
import Photos
import WebKit

class Utilities {
    static let shared:Utilities = {
        let instance = Utilities.init()
        return instance
    }()
    
    let Device:DeviceUtilities = DeviceUtilities()
    
    let userDefaullt:UserDefault = UserDefault.current
    
    typealias CompletionHandlerClosureType = (_ success: Bool, _ items: [Any]?) -> ()
    
    func showAlertView(atView:UIViewController, withTitle:String? = nil, withMessage:String? = nil, withOKAction:String? = nil, withCancelAction:String? = nil, confirmPressed:CompletionHandlerClosureType?=nil)
    {
        let alertController = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
        
        if (withOKAction != nil) {
            let okAction = UIAlertAction(title: withOKAction, style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                confirmPressed?(true,nil)
            })
            alertController.addAction(okAction)
        }
        
        if (withCancelAction != nil) {
            let cancelAction = UIAlertAction(title:withCancelAction, style: UIAlertAction.Style.cancel, handler: {
                (action: UIAlertAction!) -> Void in
                confirmPressed?(false,nil)
            })
            
            alertController.addAction(cancelAction)
        }
        
        
        
        atView.present(alertController, animated: true, completion: nil)
    }
    
    func dequeueReusableTableViewCell(withNibName nibName: String?, for tableView: UITableView?) -> UITableViewCell? {
        var cell: UITableViewCell? = tableView?.dequeueReusableCell(withIdentifier: nibName ?? "")
        if cell == nil {
            tableView?.register(UINib(nibName: nibName ?? "", bundle: nil), forCellReuseIdentifier: nibName ?? "")
            cell = tableView?.dequeueReusableCell(withIdentifier: nibName ?? "")
        }
        return cell
    }
    
    var showADBanner:Bool = false
    
    var statusBarHeight:Int {
        return Int(UIApplication.shared.statusBarFrame.height)
    }
    
    var homeIndicatorHeight:Int {
        return Device.isIPhoneXOrNew ? 34 : 0
    }
    
    var isOnDeviceNotification: Bool {
        get {
            if #available(iOS 10.0, *) {
                var notificationSettings: UNNotificationSettings?
                let semasphore = DispatchSemaphore(value: 0)
                
                DispatchQueue.global().async {
                    UNUserNotificationCenter.current().getNotificationSettings { setttings in
                        notificationSettings = setttings
                        semasphore.signal()
                    }
                }
                
                semasphore.wait()
                guard let authorizationStatus = notificationSettings?.authorizationStatus else { return false }
                return authorizationStatus == .authorized
            } else {
                return UIApplication.shared.isRegisteredForRemoteNotifications
            }
        }
    }
    
    var deviceId : String {
        get {
            return UIDevice.current.identifierForVendor!.uuidString
        }
    }
    
    func setupScreenBright(_ brightness : CGFloat) {
        UIScreen.main.brightness = brightness
    }
    
    var compileDate:Date
    {
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? "Info.plist"
        if let infoPath = Bundle.main.path(forResource: bundleName, ofType: nil),
           let infoAttr = try? FileManager.default.attributesOfItem(atPath: infoPath),
           let infoDate = infoAttr[FileAttributeKey.creationDate] as? Date
        { return infoDate }
        return Date()
    }
    
    func getImage(url:String, placeholder:UIImage? = nil, completion: @escaping (UIImage?) -> ()) {
        if let imageUrl = URL(string:url) {
            KingfisherManager.shared.retrieveImage(with: imageUrl) { (result) in
                if let image = try? result.get().image {
                    completion(image)
                }else {
                    completion(placeholder)
                }
            }
        }else {
            completion(placeholder)
        }
    }
    
    func permissionDenied(msg: String = "")
    {
        DispatchQueue.main.async {
        
            let alertText = msg
            
            let alertButton = "Setting"
            var goAction = UIAlertAction(title: alertButton, style: .default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!)
            {
                
                goAction = UIAlertAction(title: alertButton, style: .default, handler: {(alert: UIAlertAction!) -> Void in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(URL(string:UIApplication.openSettingsURLString)!)
                    }
                })
            }
            
            let alert = UIAlertController(title: nil, message: alertText, preferredStyle: .alert)
            alert.addAction(cancelAction)
            alert.addAction(goAction)
            
            var vw = appDelegate.window?.rootViewController
            
            while vw?.presentedViewController != nil {
                vw = vw?.presentedViewController
            }
            
            vw!.present(alert, animated: false, completion: nil)
        }
    }
    
    func checkPhotoLibraryAuthStatus(completion: @escaping (Bool) -> ()) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                DispatchQueue.main.async {
                    if newStatus ==  PHAuthorizationStatus.authorized {
                        completion(true)
                    }else{
                        self.permissionDenied(msg: "permission_text_photolibrarymessage_298")
                        completion(false)
                    }
                }})
            break
        case .restricted, .denied:
            self.permissionDenied(msg: "permission_text_photolibrarymessage_298")
            completion(false)
            break
        }
    }

}

func openExternalApp(urlStr: String) -> Bool{
    let scheme = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    if let url = URL(string: scheme) {
        if !UIApplication.shared.canOpenURL(url) {
            return false
        }else{
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
            return true
        }
        
    }else{
        return false
    }
}

let reachabilityManager = NetworkReachabilityManager(host: APIConstant.endpoint)

func startNetworkReachabilityObserver() {
    reachabilityManager?.listener = { status in
        switch status {
        case .notReachable:
            NotificationCenter.default.post(name: "NoNetwork".toNotificaionName(), object: NSNumber(value: true))
            break
        case .unknown, .reachable(_) :
            NotificationCenter.default.post(name: "NoNetwork".toNotificaionName(), object: NSNumber(value: false))
            break
        }
    }
    // start listening
    reachabilityManager?.startListening()
}

class QRCode {
    static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}

class WebCacheCleaner {
    class func clean() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}

struct Connectivity {
    static let sharedInstance = NetworkReachabilityManager()!
    static var isConnectedToInternet:Bool {
        return self.sharedInstance.isReachable
    }
}
