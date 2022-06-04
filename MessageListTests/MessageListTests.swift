//
//  MessageListTests.swift
//  MessageListTests
//
//  Created by David Figueroa on 3/06/22.
//

import XCTest
@testable import MessageList
import Combine

class MessageListTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor func testPosts() throws {
        
        let expectation = self.expectation(description: "getPosts")
        let viewModel = ViewModel(postsPublisher: PostStorage.shared.posts.eraseToAnyPublisher())
        
        viewModel.fetchPosts { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5)

        XCTAssertGreaterThan(viewModel.posts.count, 50)
    }
    
    @MainActor func testFavorites() throws {
        //given
        let expectation = self.expectation(description: "getPosts")
        let viewModel = ViewModel(postsPublisher: PostStorage.shared.posts.eraseToAnyPublisher())
        
        //when
        viewModel.fetchPosts { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        //then
        if let firstItem = viewModel.posts.first {
            viewModel.setAsFavorite(post: firstItem)
            XCTAssertTrue(firstItem.isFavorite)
        }
        
        waitForExpectations(timeout: 5)
    }
    
    @MainActor func testDeleteAll() throws {
        //given
        let expectation = self.expectation(description: "getPosts")
        let viewModel = ViewModel(postsPublisher: PostStorage.shared.posts.eraseToAnyPublisher())
        
        //when
        viewModel.fetchPosts { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5)
        
        //then
        PostStorage.shared.deleteAll()
        XCTAssertEqual(viewModel.posts.count, 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
