//
//  CodableFeedStoreTests.swift
//  EssentialFeed
//
//  Created by Elena Rubilova on 12/2/24.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map {$0.local}
        }
    }
    
    public struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
                    return completion(.empty)
                }

                let decoder = JSONDecoder()
                let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}
class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
            super.setUp()

            setupEmptyStoreState()
        }
    
    override func tearDown() {
            super.tearDown()

            setupEmptyStoreState()
        }
    
    
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from empty cache to deliver same empty result, got result: \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let exp = expectation(description: "Wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)
        
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let exp = expectation(description: "Wait for cache retrieval")
        let timestamp = Date()
        
        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFound), .found(secondFound)):
                        XCTAssertEqual(firstFound.feed, feed)
                        XCTAssertEqual(secondFound.feed, feed)
                        XCTAssertEqual(firstFound.timestamp, timestamp)
                        XCTAssertEqual(secondFound.timestamp, timestamp)
                    default:
                        XCTFail("Expected found results with feed \(feed) and timestamp \(timestamp), got results: \(firstResult) and \(secondResult) instead")
                    }
                    exp.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 1)
    }
    
    // - MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
            let exp = expectation(description: "Wait for cache retrieval")

            sut.retrieve { retrievedResult in
                switch (expectedResult, retrievedResult) {
                case (.empty, .empty):
                    break

                case let (.found(expected), .found(retrieved)):
                    XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
                    XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)

                default:
                    XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
                }

                exp.fulfill()
            }

            wait(for: [exp], timeout: 1.0)
        }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of:self)).store")
    }
    
    private func setupEmptyStoreState() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
