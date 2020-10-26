
import UIKit
import RxSwift
import Alamofire

extension Observable {
    func showLoadingDialog() -> Observable<Element> {
        return self.do(onSubscribed: {
            LoadingIndicator.show()
        }, onDispose: {
            LoadingIndicator.hide()
        })
    }

    func showErrorAlert() -> Observable<Element> {
        return self.do(onError: { (error) in
            UIApplication.topViewController()?.showErrorAlert(error: error)
        })
    }

}

extension Observable where Element == (HTTPURLResponse, [String:Any]) {

    func logAPIResponse(url: URLConvertible, headers:[String:String]?, parameters:[String:Any]?) -> Observable<(HTTPURLResponse, [String:Any])> {

        var requestJsonString:String? = nil
        var responseJsonString:String? = nil
        if let jsonData = try? JSONSerialization.data(withJSONObject: parameters ?? [:], options: .prettyPrinted){
            requestJsonString = String(data: jsonData, encoding: .utf8)
        }

        var startTimeStamp: CFTimeInterval = 0

        return self.do(onNext: { (response, result) in
            let duration = CACurrentMediaTime() - startTimeStamp
            if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted){
                responseJsonString = String(data: jsonData, encoding: .utf8)
            }

            if Logger.logLevel >= LogLevel.debug {
                Logger.debug(tag: "Network",
                    """
                    
                    ================================================================================
                    API Response [\(String(format: "%.3f", duration))s]: \(response.url?.path ?? "") (Thread ID: \(response.allHeaderFields["Thread-ID"] ?? "(-- nil --)"))
                    ================================================================================
                    -- Request --
                    Param:
                    \(requestJsonString ?? "(-- no param --")",

                    Header:
                    \(headers ?? [:])

                    -- Response --
                    Data:
                    \(responseJsonString ?? "(-- no response --")

                    Header:
                    \(response.allHeaderFields as? [String : String] ?? [:])
                    """
                )
            } else {
                Logger.info(tag: "Network", "API: \(response.url?.path ?? "") call success in \(String(format: "%.3f", duration))s")
            }
        }, onError: { (error) in
            guard let responseError = error as? ResponseError else { return }
            Logger.error(tag: "Network",
                """

                ==============
                🔴 API FAILURE:
                ==============
                URL:
                \(url), \(responseError.description)
                Request Header:
                \(headers ?? [:])
                Request Param:
                \(requestJsonString ?? "(-- no param --)")",
                ThreadID: \(responseError.rawResponse?.response?.allHeaderFields["Thread-ID"] as? String ?? "(-- nil --)")
                """
            )
        }, onSubscribe: {
            startTimeStamp = CACurrentMediaTime()
        })

    }
}
