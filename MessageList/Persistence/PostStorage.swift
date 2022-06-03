//
//  PostStorage.swift
//  MessageList
//
//  Created by David Figueroa on 3/06/22.
//

import Combine
import CoreData

class PostStorage: NSObject, ObservableObject {
    
    var posts = CurrentValueSubject<[PostCD], Never>([])
    private let messagesFetchController: NSFetchedResultsController<PostCD>
    var viewContext = PersistenceController.shared.container.viewContext
    
    static let shared: PostStorage = PostStorage()
    
    private override init() {
        let fetchRequest = PostCD.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PostCD.timestamp, ascending: true)]
        messagesFetchController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: PersistenceController.shared.container.viewContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        super.init()
        
        messagesFetchController.delegate = self
        
        do {
            try messagesFetchController.performFetch()
            posts.value = messagesFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func storePosts(posts: [PostModel]) {
        for post in posts {
            let newPost = PostCD(context: viewContext)
            newPost.timestamp = Date()
            newPost.postId = Int16(post.postId)
            newPost.id = Int16(post.id)
            newPost.name = post.name
            newPost.email = post.email
            newPost.body = post.body
        }
        
        do {
            try viewContext.save()
        } catch {
            
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addPost(post: PostCD) {
        let newPost = PostCD(context: viewContext)
        newPost.timestamp = Date()
        
        do {
            try viewContext.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deletePosts(offsets: IndexSet) {
        offsets.map { posts.value[$0] }.forEach(viewContext.delete)
        
        do {
            try viewContext.save()
        } catch {
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

extension PostStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller:
                                           NSFetchedResultsController<NSFetchRequestResult>) {
        guard let Posts = controller.fetchedObjects as? [PostCD] else { return }
        self.posts.value = Posts
    }
}
