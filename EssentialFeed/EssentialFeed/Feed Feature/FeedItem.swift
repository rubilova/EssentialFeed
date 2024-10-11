//
//  Copyright © Essential Developer. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
	public let id: UUID
	public let description: String?
	public let location: String?
	public let imageURL: URL
    //public let image: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
        //self.image = imageURL
    }
    
    enum codingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}


