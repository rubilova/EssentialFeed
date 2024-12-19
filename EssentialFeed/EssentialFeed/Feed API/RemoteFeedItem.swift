//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Elena Rubilova on 11/12/24.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

