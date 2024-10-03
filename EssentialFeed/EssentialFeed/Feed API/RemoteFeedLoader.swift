//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Elena Rubilova on 10/3/24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
