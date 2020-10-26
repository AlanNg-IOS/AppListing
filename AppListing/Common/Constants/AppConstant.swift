
import Foundation
import UIKit

//TODO: - Add your common constant here
public struct AppConstant {
    
    static func getUUID() -> String {
        let uuid: String
        if let savedUUID = UserDefaults.standard.string(forKey: UserDefaultKey.uuid) {
            uuid = savedUUID
        } else {
            if let vendorUUID = UIDevice.current.identifierForVendor?.uuidString.lowercased() {
                uuid = vendorUUID
            } else {
                uuid = UUID().uuidString.lowercased()
            }
            UserDefaults.standard.set(uuid, forKey: UserDefaultKey.uuid)
        }
        return uuid
    }
    
    static func DEVICE_OS_VERSION() -> String {
        return UIDevice.current.systemVersion
    }
    
    static func DEVICE_APP_VERSION() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return version ?? ""
    }
    
    static func DEVICE_IP() -> String {
        return "127.0.0.1"
    }
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenheight = UIScreen.main.bounds.height
}


struct UserDefaultKey {
    //TODO: - Add your key here for store at UserDefault
    static let firstRun = "firstRun"
    static let uuid = "UUID"
    static let accessToken = "accessToken"
    static let refreshToken = "refreshToken"
    static let pushToken = "pushToken"
    static let deviceToken = "deviceToken"
    static let initChecking = "initChecking"
    static let listData = "listData"
    static let recommendListData = "recommendListData"
}

extension UserDefaults {
    static var key = UserDefaultKey.self
}

extension Notification.Name {
    static let languageDidChange = "languageDidChange".toNotificaionName()
}
