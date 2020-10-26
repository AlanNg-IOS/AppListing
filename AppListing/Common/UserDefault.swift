
import Foundation
import UIKit

class UserDefault {
    static let current = UserDefault()
    
    private var userDefault = UserDefaults.standard
    
    private init() {
        
    }
    
    var firstRun: Bool! {
        get { return userDefault.bool(forKey: UserDefaultKey.firstRun) }
        set { userDefault.set(newValue, forKey: UserDefaultKey.firstRun) }
    }

    var pushToken:String {
        get { return userDefault.string(forKey: UserDefaultKey.pushToken) ?? "" }
        set {
            userDefault.set(newValue, forKey: UserDefaultKey.pushToken)
        }
    }
    
    var deviceToken:String {
        get{
            return userDefault.string(forKey: UserDefaultKey.deviceToken) ?? ""
        }
        
        set {
            userDefault.set(newValue, forKey: UserDefaultKey.deviceToken)
        }
    }
    
    var initChecking:Bool {
        get{
            return userDefault.bool(forKey: UserDefaultKey.initChecking)
        }
        
        set {
            userDefault.set(NSNumber(value: newValue), forKey: UserDefaultKey.initChecking)
            //  userDefaullt.synchronize()
        }
    }
    
    var listData: ListingFeedResponse? {
        get { guard let data = userDefault.object(forKey: UserDefaultKey.listData) as? Data else {
                return nil
            }
            return try? WebServices.decoder.decode(ListingFeedResponse.self, from: data)
        }
        
        set {
            
            if newValue == nil {
                userDefault.set(nil, forKey: UserDefaultKey.listData)
            }else {
                let encodedResponse = try? WebServices.encoder.encode(newValue)
                userDefault.set(encodedResponse, forKey: UserDefaultKey.listData)
            }
        }
    }
    
    var recommendListData: ListingFeedResponse? {
        get { guard let data = userDefault.object(forKey: UserDefaultKey.recommendListData) as? Data else {
                return nil
            }
            return try? WebServices.decoder.decode(ListingFeedResponse.self, from: data)
        }
        
        set {
            
            if newValue == nil {
                userDefault.set(nil, forKey: UserDefaultKey.recommendListData)
            }else {
                let encodedResponse = try? WebServices.encoder.encode(newValue)
                userDefault.set(encodedResponse, forKey: UserDefaultKey.recommendListData)
            }
        }
    }
    
    //MARK: - store Data
    func setData(_ value: Any?, key: String) {
        let ud = UserDefaults.standard
        if let theValue = value {
            let archivedPool = NSKeyedArchiver.archivedData(withRootObject: theValue)
            ud.set(archivedPool, forKey: key)
        }else {
            ud.set(nil, forKey: key)
        }
    }
    
    func getData<T>(key: String) -> T? {
        let ud = UserDefaults.standard
        if let val = ud.value(forKey: key) as? Data,
            let obj = NSKeyedUnarchiver.unarchiveObject(with: val) as? T {
            return obj
        }
        
        return nil
    }
}

