
import Alamofire

struct RequestOption: OptionSet {
    let rawValue: Int

    static let noLoadingIndicator = RequestOption(rawValue: 1)
    static let noDefaultErrorAlert = RequestOption(rawValue: 2)
    static let noDefaulApiErrorAlert = RequestOption(rawValue: 4)

}

public struct MappableRequest<Model: Decodable> {
    let method: HTTPMethod
    let url: URL
    let param: [String: Any]?
    let encoding: ParameterEncoding
    var header: [String: String]?
    var requestOptions: RequestOption = []

    init(method: HTTPMethod = .post, releativeURL: String, param: [String:Any], encoding: ParameterEncoding = JSONEncoding.default, header: [String:String]? = nil) {
        let url = URL(string: APIConstant.endpoint)!.appendingPathComponent(releativeURL)
        self.init(method: method, absoluteURL: url, param: param, encoding: encoding, header: header)
    }

    init(method: HTTPMethod, absoluteURL: URL, param: [String:Any], encoding: ParameterEncoding, header: [String:String]? = nil) {
        self.method = method
        self.url = absoluteURL
        self.param = param
        self.encoding = encoding
        self.header = header
    }
}

public struct MultipartData {

    public enum MineType: String {
        case jpeg = "image/jpeg", png = "image/png", videoMP4 = "video/mp4"
    }

    let name: String
    let fileName: String
    let data: Data
    let mimeType: MineType
}

public struct MappableMultipartRequest<Model: Decodable> {
    let method: HTTPMethod = .post
    let url: URL
    var data: [MultipartData] = []
    let encoding: ParameterEncoding
    var header: [String: String]?
    var requestOptions: RequestOption = []

    init(releativeURL: String, data: [MultipartData], encoding: ParameterEncoding = JSONEncoding.default, header: [String:String]? = nil) {
        let url = URL(string: APIConstant.endpoint)!.appendingPathComponent(releativeURL)
        self.init(absoluteURL: url, data: data, encoding: encoding, header: header)
    }

    init(absoluteURL: URL, data: [MultipartData], encoding: ParameterEncoding, header: [String:String]? = nil) {
        self.url = absoluteURL
        self.data = data
        self.encoding = encoding
        self.header = header
    }
}
