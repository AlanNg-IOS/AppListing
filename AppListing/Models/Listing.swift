
import Foundation

struct ListingResponse: Codable {
    let feed: ListingFeedResponse?
}

struct ListingFeedResponse: Codable {
    let entry: [Listing]
}

struct ListItemResponse: Codable {
    let results: [ItemDetail]
}

struct ItemDetail: Codable {
    let trackId: Int
    let userRatingCount: Int
    let averageUserRating: Double
}

struct Listing: Codable {
    let id: TrackId?
    let category: Category?
    let name: Attributes?
    let im_image:[Attributes]?
    let summary: Attributes?
    let im_artist: Attributes?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case category
        case name = "im:name"
        case im_image = "im:image"
        case summary
        case im_artist = "im:artist"
    }
}
struct TrackId: Codable {
    let attributes: Attributes?
}

struct Category: Codable {
    let attributes: Attributes?
}

struct Attributes: Codable {
    let im_id: String?
    let label: String?
    
    private enum CodingKeys: String, CodingKey {
        case im_id = "im:id"
        case label
    }
}

