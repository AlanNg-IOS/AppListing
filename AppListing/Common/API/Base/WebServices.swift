
import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import KRProgressHUD

class WebServices {
    // Prevent duplicate pop up
//    private static var maintenanceError : Error?
//    private static var maintenanceObserable : Observable<Bool> = {
//        return Observable.deferred {
//            return Observable<()>.create({ (observer) -> Disposable in
//                if let error = maintenanceError as? ResponseError {
//                    let jsonValue = error.rawResponse?.value as? [String:Any]
//                    let titleString = jsonValue?["title"] as? String
//                    let contentString = jsonValue?["display_message"] as? String
//                    LoadingIndicator.hide()
//                    appDelegate.handleErrorAlert(error: error, title: titleString, content: contentString, completion: { success in
//                        exit(0)
//                    })
//
//                } else {
//                    observer.onNext(())
//                    observer.onCompleted()
//                }
//                return Disposables.create()
//            }).flatMap({ (_) -> Observable<Bool> in
//                return Observable.error(maintenanceError ?? NSError())
//            })
//        }.share()
//    }()
//
//    private static func maintenanceHandle(error: Error) -> Observable<Bool> {
//        maintenanceError = error
//        return maintenanceObserable
//    }
//
//    private static var refreshTokenObservable: Observable<Bool> = {
//        return Observable.deferred {
//            var request = WebServices.RequestModule.Settings.getOAuthRefreshToken()
//            request.requestOptions = [.noLoadingIndicator, .noDefaulApiErrorAlert, .noDefaultErrorAlert]
//
//            return WebServices.requestModel(request: request).retry(3)
//                .do(onNext: { (response) in
//                    guard let data = response.result else { return }
//                    guard let tokenType = data.token_type else { return }
//                    guard let accessToken = data.access_token else { return }
//                    guard let refreshToken = data.refresh_token else { return }
//
//                    let tokenString =  tokenType + " " + accessToken
//                    UserDefault.current.accessToken = tokenString
//                    UserDefault.current.refreshToken = refreshToken
//                }).flatMap({ (apiResult) -> Observable<Bool> in
//                    if apiResult.success == false {
//                        return LoginObservable
//                    }
//                    return Observable.just(true)
//                })
//        }.share(replay: 1)
//
//    }()
//
//    private static var LoginObservable: Observable<Bool> = {
//        return Observable.deferred {
//
//            var request = WebServices.RequestModule.Settings.getOAuthToken(name: "oauth_user", pwd: "123456")
//            request.requestOptions = [.noLoadingIndicator]
//
//            return WebServices.requestModel(request: request)
//                .do(onNext: { (response) in
//                    guard let data = response.result else { return }
//                    guard let tokenType = data.token_type else { return }
//                    guard let accessToken = data.access_token else { return }
//                    guard let refreshToken = data.refresh_token else { return }
//
//                    let tokenString =  tokenType + " " + accessToken
//                    UserDefault.current.accessToken = tokenString
//                    UserDefault.current.refreshToken = refreshToken
//                }).flatMap({ _ in Observable.just(true)})
//        }.share(replay: 1)
//    }()
    
    static let encoder:JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }()

    static let decoder:JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }()

    static func jsonDict<T:Encodable>(from object:T) throws -> [String:Any]? {
        let encodedData = try WebServices.encoder.encode(object)
        let dict = try JSONSerialization.jsonObject(with: encodedData, options: .allowFragments) as? [String:Any]
        return dict
    }
    
    static let afSessionManager:Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let manager = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: nil)
        return manager
    }()
    
    private static let challengeHandler: ((URLSession, URLAuthenticationChallenge) -> (URLSession.AuthChallengeDisposition, URLCredential?))? = { result, challenge in
        return (.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }

    let request: Request

    init(request: Request) {
        self.request = request
    }

    // MARK: - Public function

    static func requestJSON(_ method: Alamofire.HTTPMethod = .post,
                            _ url: URLConvertible,
                            parameters: [String: Any]? = nil,
                            encoding: ParameterEncoding = JSONEncoding.prettyPrinted,
                            headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, [String:Any])> {

        let request = WebServices.afSessionManager.rx
            .request(method, url, parameters: parameters, encoding: encoding, headers: headers).validate()
            .responseJSON()

        let response = WebServices.responseJSON(dataResponse: request, url: url)

        #if DEBUG
            Logger.debug(tag: "Network", "Start API Request: URL: \(url), param: \(parameters ?? [:])")
            return response.logAPIResponse(url: url, headers: headers, parameters: parameters)
        #else
            return response
        #endif

    }

    static func requestModel<M>(request: MappableRequest<M>) -> Observable<Response<M>> {
        let url = request.url

        var requestObservable: Observable<Response<M>> = Observable
            .deferred { () -> Observable<(HTTPURLResponse, [String:Any])> in
                let headers = WebServices.getAuthTokenHeaders(headers: request.header ?? [:], url: url.absoluteString)
                return WebServices.requestJSON(request.method, url, parameters: request.param, encoding: request.encoding, headers: headers)
            }
            .map(WebServices.mapResponseToModel)
            .do(onNext: { (response) in
                //TODO: add your code here for checking all api response
                ///Example: send GA Event if need
                if !(response.success ?? true), !request.requestOptions.contains(RequestOption.noDefaulApiErrorAlert)  {
                    let resultCode = ResultCode(code: response.return_code ?? 0, message: response.display_message ?? "", title: response.title ?? "")
                    throw ResponseError(errorType: .apiError(resultCode: resultCode), url: url, resultCode: resultCode)
                }
                
            })
        if !request.requestOptions.contains(RequestOption.noDefaultErrorAlert) {
            requestObservable = requestObservable.showErrorAlert()
        }

        if !request.requestOptions.contains(RequestOption.noLoadingIndicator) {
            requestObservable = requestObservable.showLoadingDialog()
        }


        return requestObservable

    }

    //MARK: - Helper Function

//    private static func handleColonKey(value: Any) -> Any{
//        var tmp = value
//        if var dict = value as? Dictionary<String, Any> {
//            for (key, finalValue) in dict {
//                var newKey = ""
//                if key.contains(":") {
//                    newKey = key.replacingOccurrences(of: ":", with: "_")
//                    dict.removeValue(forKey: key)
//                    dict[newKey] = finalValue
//                }
//            }
//            tmp = dict
//        } else if let ary = value as? Array<Any> {
//            for value in ary {
//                return handleColonKey(value: value)
//            }
//        }
//        return tmp
//    }
    
    private static func mapResponseToModel<M>(httpResponse: HTTPURLResponse, json: [String:Any]) throws -> Response<M> {
        do {
            
//            var tmpJson = handleColonKey(value: json)
            
//            for (key, value) in tmpJson {
//                var tmpValue = value
//                if var dict1 = value as? Dictionary<String, Any> {
//                    for (key, value) in dict1 {
//                        var tmpArray: [Dictionary<String, Any>] = []
//                        if var dict2 = value as? Array<Any> {
//                            for value in dict2 {
//                                if var dict3 = value as? Dictionary<String, Any> {
//                                    for (finalKey, finalValue) in dict3 {
//                                        var newKey = ""
//                                        if finalKey.contains(":") {
//                                            newKey = finalKey.replacingOccurrences(of: ":", with: "_")
//                                            dict3.removeValue(forKey: finalKey)
//                                            dict3[newKey] = finalValue
//                                        }
//                                    }
//                                    tmpArray.append(dict3)
//                                }
//                            }
//                        }
//                        dict1[key] = tmpArray
//                    }
//                    tmpValue = dict1
//                }
//                tmpJson[key] = tmpValue
//            }
            
            
            
            var resposne = try WebServices.mapJsonToModel(["Data":json], modelType: Response<M>.self)
//            resposne.threadId = httpResponse.allHeaderFields["Thread-ID"] as? String
            return resposne
        } catch let error as DecodingError {
            Logger.error(tag: "Network", "Parse JSON Error: ", error)
            let url = httpResponse.url
            
            let resultCode = try WebServices.getResuleCode(json: json, url: url)
            if resultCode.isValid {
                throw ResponseError(errorType: .parseJSONError(decodingError: error), url: url, resultCode: resultCode)
            } else {
                throw ResponseError(errorType: .apiError(resultCode: resultCode), url: url, resultCode: resultCode)
            }
        }
    }
    
    private static func responseJSON(dataResponse: Observable<DataResponse<Any>>, url: URLConvertible) -> Observable<(HTTPURLResponse, [String:Any])> {
        return dataResponse
            .map { (response) -> (HTTPURLResponse, [String:Any]) in

                let url = response.request?.url

                guard let httpResponse = response.response else {
                    throw ResponseError(errorType: .httpError(statusCode: response.response?.statusCode ?? -1), url: url)
                }

                guard let jsonValue = response.value as? [String:Any] else {
                    throw ResponseError(errorType: .notJSON(rawResponse: httpResponse), url: url)
                }
                
                if let resultCode = try? WebServices.getResuleCode(json: jsonValue, url: url), resultCode.code == ResultCode.CodeDefinition.maintenance {
                    throw ResponseError(errorType: .maintenance, url: url, rawResponse: response, resultCode: resultCode)
                }

                return (httpResponse, jsonValue)
            }
            .catchError { (error) -> Observable<(HTTPURLResponse, [String:Any])> in

                if case AFError.responseSerializationFailed = error {
                    return Observable.error(ResponseError(errorType: .notJSON(rawResponse: nil), url: try? url.asURL()))
                }

                let nsError = error as NSError

                guard nsError.domain == "NSURLErrorDomain" else {
                    throw error
                }

                /// Convert nsError to ResponseError format
                let url = try? url.asURL()
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
                    throw ResponseError(errorType: .noNetworkConnection(nsError), url: url)
                case NSURLErrorTimedOut:
                    throw ResponseError(errorType: .connectionTimeout(nsError), url: url)
                default:
                    throw ResponseError(errorType: .unexpectedError(message: nil, error: nsError), url: url)
                }

        }

    }

    private static func getAuthTokenHeaders(headers: [String:String], url:String = "") -> [String:String] {
        var headers: [String : String] = headers
        
        headers["Device-OS"] = "IOS"
        
        headers["Content-Type"] = "application/json"
        
        headers["Device-ID"] = AppConstant.getUUID()
        headers["Device-OS-Version"] = AppConstant.DEVICE_OS_VERSION()
        headers["App-Version"] = AppConstant.DEVICE_APP_VERSION()
        headers["Device-IP"] = AppConstant.DEVICE_IP()
        
        return headers
    }

    private static func getResuleCode(json: [String:Any], url: URL?) throws -> ResultCode {
        //TODO: - change key "rc" to match api result code return
        guard let resultCodeJson = json["return_code"] as? Int else {
            throw ResponseError(errorType: .jsonAttributeNotFound(attributeName: "return_code", dict: json), url: url)
        }
        
        guard let resultMessage = json["display_message"] as? String else {
            throw ResponseError(errorType: .jsonAttributeNotFound(attributeName: "display_message", dict: json), url: url)
        }
        
        guard let title = json["title"] as? String else {
            throw ResponseError(errorType: .jsonAttributeNotFound(attributeName: "title", dict: json), url: url)
        }
        
        return ResultCode.init(code: resultCodeJson, message: resultMessage, title: title)
    }

    static func mapJsonToModel<M>(_ jsonDict:Any, modelType:M.Type) throws -> M where M:Decodable {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        let model = try WebServices.decoder.decode(modelType, from: jsonData)
        return model
    }

}
