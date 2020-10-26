
import Foundation
import UIKit
import CoreLocation

extension String{
    func substringByRange(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start..<end])
    }
    func substring(to: Int) -> String {
        let toIndex = self.index(startIndex, offsetBy: to)
        return String(self[..<toIndex])
    }
    func substring(from: Int) -> String {
        let fromIndex = self.index(startIndex, offsetBy: from)
        return String(self[fromIndex...])
    }
    
    func isNewVersion(compareVersion: String) -> Bool {
        if self.compare(compareVersion, options: String.CompareOptions.numeric) == ComparisonResult.orderedDescending {
            return true
        }
        return false
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive) != nil
    }
    
    func toNotificaionName() -> NSNotification.Name {
        return Notification.Name(self)
    }
    
    func toPhoneNumLink() -> String{
        let str = self.replacingOccurrences(of: " ", with: "")
        return ("tel://\(str)")
    }
    
    func toEmailLink() -> String{
        let str = self.replacingOccurrences(of: " ", with: "")
        return ("mailto:\(str)")
    }
    
    func toWebsiteLink() -> String{
        if self.hasPrefix("http") {
            return self
        }
        return ("https://\(self)")
    }
    
    func toURL() -> URL{
        if self.isEmpty {
            return URL(string: "null")!
        }
        if self.contains(" ") {
            return URL(string: "null")!
        }
        
        return URL(string: self) ?? URL(string: "null")!
    }
    
    func toURLwithEncoding() -> URL?{
        let csCopy = CharacterSet(bitmapRepresentation: CharacterSet.urlPathAllowed.bitmapRepresentation)
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: csCopy) ?? "null")
    }
    
    func compareYearDiffernece(format: String = "yyyy-MM-dd") -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-01"
        let now = dateFormatter.string(from: Date())
        
        if let date = self.toDate(format: format), let now = now.toDate(format: "yyyy-MM-01") {
            let ageComponents = Calendar.current.dateComponents([.year], from: date, to: now)
            return ageComponents.year ?? 0
        }
        
        return 0
    }
    
    func toDateString(format: String, originDateFormat dateFormat:String?=nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US")
        
        if let date = self.toDate(format:dateFormat ?? "yyyy-MM-dd HH:mm:ss") {
            return dateFormatter.string(from: date)
        }
        
        return ""
    }
    
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
    func readableDate() -> String {
        return ""
    }
    
    func isDatePassed() -> Bool {
        let date:Date = Date()
        if let targetDate = self.toDate(format:"yyyy-MM-dd HH:mm:ss"){
            return date > targetDate
        }
        return false
    }
    
    var containsChineseCharacters: Bool {
        return self.range(of: "\\p{Han}", options: .regularExpression) != nil
    }
    
    func convertToPhoneFormat(prefix : String = "") -> String {
        let firstComponent = self.substring(to: 4)
        let secondComponent = self.substring(from: 4)
        
        return prefix + firstComponent + " " + secondComponent
    }
    
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, options: [], range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
    
    func convertToLocationDegrees() -> CLLocationDegrees {
        return CLLocationDegrees(Double(self)!)
    }
    
    func formatPoint(withDecimalPlace place: Int = 0) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.minimumFractionDigits = place
        numberFormatter.maximumFractionDigits = place
        numberFormatter.roundingMode = .floor
        if let myNumber = Double(self) {
            return numberFormatter.string(from: NSNumber(value:myNumber))!
        }else{
            return numberFormatter.string(from: NSNumber(value:0))!
        }
    }
    
    func phoneNumFormat(to: String) -> String {
        var phone = ""
        #if HK
        let slice = ArraySlice(self)
        for (index, digit) in slice.enumerated() {
            if (index) % 4 == 0 && index != 0 {
                phone += to
                print(to)
            }
            phone += String(digit)
        }
        
        #else
        let slice = ArraySlice(self)
        for (index, digit) in slice.enumerated() {
            if index % 4 == 0 && index != 0 {
                phone += to
            }
            phone += String(digit)
        }
        #endif
        
        return phone
    }
}
