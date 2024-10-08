//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Elena Rubilova on 10/3/24.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Error?, HTTPURLResponse?) -> Void)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void ) {
        client.get(from: url, completion: { error, response in
            if response != nil {
                completion(.invalidData)
            } else {
                completion(.connectivity)
            }
            
        })
    }
}
