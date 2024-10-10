//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Elena Rubilova on 10/3/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case succeess([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void ) {
        client.get(from: url, completion: { result in
            switch result {
                case .success:
                completion(.failure(.invalidData))
                case .failure:
                completion(.failure(.connectivity))
            }
            
        })
    }
}
