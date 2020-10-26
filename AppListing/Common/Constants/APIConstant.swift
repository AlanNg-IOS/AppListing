
import Foundation

struct APIConstant {
    
    static let endpoint: String = "https://itunes.apple.com/hk"
    static let URLScheme: String = "AppListing"
    
    static let APITopFreeListing = "/rss/topfreeapplications/limit=100/json"
    static let APILookUp = "/lookup"
    static let APIRecommendListing = "/rss/topgrossingapplications/limit=10/json"
    
}
