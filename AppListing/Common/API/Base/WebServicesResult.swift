
import Foundation
import Alamofire

struct GeneralEmptyDataResponse:Decodable { }

public struct ResultCode: Codable {
    var code: Int = 1
    var message: String = ""
    var sysMessage: String = ""
    var title: String = ""

    var isValid: Bool { // Check the request is success return or not
        //TODO: change the vaild code 
//        return self.code / 1000 == 1 // 1000 ~ 1999
        return self.code == 0
    }

    struct CodeDefinition {
        //TODO: - change the code number base on server error code return
        static let invalidOAuthToken = 1000
//        static let invalidToken = 3000
        static let maintenance = 6001
    }
    
    init(code: Int, message: String, sysMessage: String? = nil, title: String? = nil) {
        self.code = code
        self.message = message
        self.sysMessage = sysMessage ?? ""
        self.title = title ?? ""
    }
    
}

protocol ResponseProtocol {
    var rc: ResultCode { get }
    var threadId: String? { get }
}

public struct Response<M:Decodable>: Decodable { //}, ResponseProtocol {
    var success: Bool?
    var return_code : Int?
    var Data: M?
    var msg: String? // Set manually, not from JSON Object, Make sure set threadId is OPTIONAL or it will fail when json mapping
    var display_message: String?
    var title: String?
    
}

struct ResponseError:Error {

    private static let mapping:[Int:String] = [
        500: "Internal Server Error",
        404: "Page not found"
    ]

    enum ErrorType {
        case noNetworkConnection(NSError)
        case connectionTimeout(NSError)
        case httpError(statusCode:Int)
        case notJSON(rawResponse:HTTPURLResponse?)
        case apiError(resultCode: ResultCode)
        case parseJSONError(decodingError: DecodingError)
        case jsonAttributeNotFound(attributeName:String, dict:[String:Any])
        case unexpectedError(message:String?, error:Error?)
        case maintenance
        case invalidOAuthToken
        case invalidRefreshToken
        case bluetooth
    }

    let errorType:ErrorType
    let url:URL?
    let rawResponse: DataResponse<Any>?
    let resultCode: ResultCode?

    /// Error description for internal debug or logging
    var description: String {
        switch self.errorType {
        case .noNetworkConnection:
            return "No network connection"
        case .httpError(let statusCode):
            return "HTTP error: \(ResponseError.mapping[statusCode] ?? "Other"), Status code: \(statusCode)"
        case .apiError(let baseResponse):
            return "API Error: \(baseResponse.sysMessage)"
        case .unexpectedError(let message, let error):
            return "UnexpectedError message: \(message ?? ""), error \(error.debugDescription)"
        case .parseJSONError(let decodingError):
            let detailMsg:String
            switch decodingError {
            case let .keyNotFound(key, ctx):
                detailMsg = "Key not found in path: \(ctx.codingPath.map({ $0.stringValue }).joined(separator: " -> ")) => \(key.stringValue)"
            case let .valueNotFound(type, ctx):
                detailMsg = "Value not found in path: \(ctx.codingPath.map({ $0.stringValue }).joined(separator: " -> ")) => \(type)"
            default:
                detailMsg = String(describing: decodingError)
            }
            return "JSON Decode error: \n\(detailMsg)"
        case .connectionTimeout(let error):
            return "Connection timeout \(error.localizedDescription)"
        default:
            return String(describing: self)
        }
    }

    /// Error message for display to user, such as UI alert popup
    var errorMessage:String {
        switch self.errorType {
        case .httpError(let statusCode):
            return "HTTP Error, Code: \(statusCode)"
        case .apiError(let baseResponse):
            return baseResponse.sysMessage
        case .connectionTimeout:
            return "Connection timeout"
        case .noNetworkConnection:
            return "No network"
        case .parseJSONError:
            return "Parse Response Error"
        default:
            #if DEBUG
                return "Error (\(self.errorType))"
            #else
                return "Unexpected error"
            #endif
        }
    }

    init(errorType: ErrorType, url: URL?, rawResponse: DataResponse<Any>? = nil, resultCode: ResultCode? = nil) {
        self.errorType = errorType
        self.url = url
        self.rawResponse = rawResponse
        self.resultCode = resultCode
    }

    init(error:Error, url: URL?) {
        switch error {
        case let error as ResponseError:
            self.init(errorType: error.errorType, url: error.url)
        case let error as DecodingError:
            self.init(errorType: .parseJSONError(decodingError: error), url: url)
        default:
            self.init(errorType: .unexpectedError(message:nil, error:error), url: url)
        }
    }

}


