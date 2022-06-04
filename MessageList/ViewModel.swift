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
    @Published var favorites = 0
    
    private var cancellable = Set<AnyCancellable>()
    private let apiClient = APIClient()
    
    init(coursePublisher: AnyPublisher<[PostCD],Never> = PostStorage.shared.posts.eraseToAnyPublisher()) {
        
        coursePublisher.sink { [weak self] posts in
            self?.posts = posts
        }.store(in: &cancellable)
        
        $favorites.sink { [weak self] flag in
            switch flag {
            case 0:
                self?.posts = PostStorage.shared.getAllPosts()
            case 1:
                self?.posts = PostStorage.shared.getAllPosts().filter({ $0.isFavorite })
            default:
                break
            }
        }.store(in: &cancellable)
    }
    
    func fetchPosts() {
        guard let request = apiClient.createRequestWithURLComponents(requestType: .getPosts) else { return }
        
        apiClient.sendRequest(model: [PostModel].self, request: request) { [weak self] resultResponse in
            switch resultResponse {
            case .success(let data):
                self?.storePosts(posts: data)
            case .failure(let error):
                print("Handle Error: " + error.localizedDescription)
            }
        }
        return
    }
    
    func storePosts(posts: [PostModel]) {
        PostStorage.shared.storePosts(posts: posts)
    }

    func addItem(post: PostCD) {
        withAnimation {
            PostStorage.shared.setAsFavorite(post: post)
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            PostStorage.shared.deletePosts(offsets: offsets)
        }
    }   
}
