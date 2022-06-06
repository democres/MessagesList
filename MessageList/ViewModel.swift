//
//  ViewModel.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import SwiftUI
import CoreData
import Combine

@MainActor class ViewModel: ObservableObject {
    @Published var posts: [PostCD] = []
    @Published var favorites = 0 {
        didSet {
            showPosts()
        }
    }
    
    private var cancellable = Set<AnyCancellable>()
    private let apiClient = APIClient()
    
    init(postsPublisher: AnyPublisher<[PostCD],Never> = PostStorage.shared.posts.eraseToAnyPublisher()) {
        
        postsPublisher.receive(on: DispatchQueue.main).sink { [weak self] posts in
            self?.posts = posts
        }.store(in: &cancellable)
    }
    
    func showPosts() {
        switch favorites {
        case 0:
            posts = PostStorage.shared.getAllPosts()
        case 1:
            posts = PostStorage.shared.getAllPosts().filter({ $0.isFavorite })
        default:
            break
        }
    }
    
    func fetchPosts(success: ((Bool) -> Void)? = nil) {
        guard let request = apiClient.createRequestWithURLComponents(requestType: .getPosts) else { return }
        
        apiClient.sendRequest(model: [PostModel].self, request: request) { [weak self] resultResponse in
            switch resultResponse {
            case .success(let data):
                self?.storePosts(posts: data)
                success?(true)
            case .failure(let error):
                print("Handle Error: " + error.localizedDescription)
                success?(false)
            }
        }
        return
    }
    
    func storePosts(posts: [PostModel]) {
        PostStorage.shared.batchInsertPosts(posts)
    }

    func setAsFavorite(post: PostCD) {
        PostStorage.shared.setAsFavorite(post: post)
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            PostStorage.shared.deletePosts(offsets: offsets)
        }
    }
}
