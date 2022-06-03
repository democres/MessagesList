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
    @Published var posts: [PostModel] = []
    
    let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private var cancellable = Set<AnyCancellable>()
    private let apiClient = APIClient()
    
    init(coursePublisher: AnyPublisher<[PostCD],Never> = PostStorage.shared.posts.eraseToAnyPublisher()) {
        
        coursePublisher.sink { [weak self] posts in
            self?.posts = posts.map({ PostModel(postId: Int($0.postId),
                                                id: Int($0.id),
                                                name: $0.name ?? "",
                                                email: $0.email ?? "",
                                                body: $0.body ?? "") })
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

    func addItem() {
        withAnimation {
            PostStorage.shared.addPost(post: PostCD())
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        withAnimation {
            PostStorage.shared.deletePosts(offsets: offsets)
        }
    }
}
