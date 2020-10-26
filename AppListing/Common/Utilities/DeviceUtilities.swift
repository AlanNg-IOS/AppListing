
import UIKit
import Foundation

struct DeviceUtilities {
    
    var isIPHONE:Bool {
        return (UI_USER_INTERFACE_IDIOM() == .phone)
    }
    var isIPAD:Bool {
        return (UI_USER_INTERFACE_IDIOM() == .pad)
    }

    var isIPhoneX:Bool{
        return (isIPHONE && UIScreen.main.nativeBounds.height == 2436)
    }
    var isIPhoneXS:Bool{
        return (isIPHONE && UIScreen.main.nativeBounds.height == 2436)
    }
    
    var isIPhoneXSMAX:Bool{
        return (isIPHONE && UIScreen.main.nativeBounds.height == 2688)
    }
    
    var isIPhoneXR:Bool{
        return (isIPHONE && UIScreen.main.nativeBounds.height == 1792)
    }
    

    var isIPhoneXOrNew:Bool {
        if isIPhoneX || isIPhoneXR || isIPhoneXS || isIPhoneXSMAX {
            return true
        }
        return false
    }

    var isIPhoneSEor5:Bool {
        if UIScreen.main.nativeBounds.height == 1136 {
            return true
        }
        return false
    }

    var isIPhone4:Bool {
        if UIScreen.main.bounds.height == 480 {
            return true
        }
        return false
    }

    var isIPhone678:Bool {
        if UIScreen.main.nativeBounds.height == 1334 {
            return true
        }
        return false
    }
    
    var isIPhone678Plus:Bool {
        if UIScreen.main.nativeBounds.height == 1920 || UIScreen.main.nativeBounds.height == 2208 {
            return true
        }
        return false
    }
}
