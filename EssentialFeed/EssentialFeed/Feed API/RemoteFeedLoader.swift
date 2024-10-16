//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Elena Rubilova on 10/3/24.
//

import Foundation

public class RemoteFeedLoader {
    private let client: HTTPClient
    private let url: URL
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = LoadFeedResult<Error>
    
    public init(url: URL, client: HTTPClient){
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void ) {
        client.get(from: url, completion: { [weak self] result in
            guard self != nil else {
                return
            }
            switch result {
                case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
                case .failure:
                    completion(.failure(.connectivity))
            }
        })
    }
    
    
}




