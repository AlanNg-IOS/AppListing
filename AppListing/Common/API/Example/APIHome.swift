
import Foundation
import RxSwift
import Alamofire
import RxAlamofire

extension WebServices {
// Important!!
    // encoding: URLEncoding.default for .get
    // encoding: JSONEncoding.default for .post
    
    struct RequestModule {
        
        struct AppListing {
            static func getFreeListing() -> MappableRequest<ListingResponse> {
                let url = APIConstant.APITopFreeListing
                
                return MappableRequest(method: .get, releativeURL: url, param: [:], encoding: URLEncoding.default)
            }
            
            static func getRecommendListing() -> MappableRequest<ListingResponse> {
                let url = APIConstant.APIRecommendListing
                
                return MappableRequest(method: .get, releativeURL: url, param: [:], encoding: URLEncoding.default)
            }
            
            static func getItemData(id: Int) -> MappableRequest<ListItemResponse> {
                let url = APIConstant.APILookUp
                return MappableRequest(method: .get, releativeURL: url, param: ["id" : "\(id)"], encoding: URLEncoding.default)
            }
        }
//            static func userLogout() -> MappableRequest<GeneralEmptyDataResponse> {
//                let url = APIConstant.APILogout
//                var params = [String : String]()
//                if let token = UserDefault.current.memberToken {
//                    params = ["token" : token]
//                }
//                return MappableRequest(method: .post, releativeURL: url, param: params)
//            }
    }
}
