
import Foundation

public enum LogLevel:Int, Comparable {
    
    case debug = 1, info = 2, warning = 3, error = 4
    
    var icon:String {
        switch self {
        case .debug:
            return "🐞"
        case .info:
            return "💡"
        case .warning:
            return "⚠️ Warning"
        case .error:
            return "💥 Error"
        }
    }
    
    public static func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct Logger {
    public static var logLevel:LogLevel = .debug
    
    public static func debug(file:String = #file, function:String = #function, tag:String? = nil, _ message:Any...) {
        let tag = getTag(file: file, function: function, tag: tag)
        Logger.log(tag: tag, level: .debug, message)
    }
    
    public static func warning(file:String = #file, function:String = #function, tag:String? = nil, _ message:Any...) {
        let tag = getTag(file: file, function: function, tag: tag)
        Logger.log(tag: tag, level: .warning, message)
    }
    
    public static func info(file:String = #file, function:String = #function, tag:String? = nil, _ message:Any...) {
        let tag = getTag(file: file, function: function, tag: tag)
        Logger.log(tag: tag, level: .info, message)
    }
    
    public static func error(file:String = #file, function:String = #function, tag:String? = nil, _ message:Any...) {
        let tag = getTag(file: file, function: function, tag: tag)
        Logger.log(tag: tag, level: .error, message)
    }
    
    public static func log(tag:String, level:LogLevel = .debug, _ message:[Any]) {
        #if DEBUG
            if level >= Logger.logLevel {
                print("\(level.icon) [\(tag)]", message.map({ String(describing: $0) }).joined(separator: "\t"))
            }
        #endif
    }
    
    public static func log(tag:String, level:LogLevel = .debug, _ message:Any...) {
        log(tag: tag, level: level, message)
    }
    
    private static func getTag(file: String, function:String, tag: String?) -> String {
        if let tag = tag {
            return tag
        } else {
            let lastPathComponent = file.split(separator: "/").last
            let filename = lastPathComponent?.replacingOccurrences(of: ".swift", with: "") ?? function
            return "\(filename):\(function)"
        }
    }
    
}
