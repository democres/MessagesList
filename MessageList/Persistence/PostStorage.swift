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
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \PostCD.timestamp,
                                                         ascending: true)]
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
    
    func getAllPosts() -> [PostCD] {
        let fetchRequest = PostCD.fetchRequest()
        if let objects = try? viewContext.fetch(fetchRequest) {
            return objects
        }
        return []
    }

    func setAsFavorite(post: PostCD) {
        post.isFavorite.toggle()
        do {
            try self.viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
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
    
    func deleteAll() {
        let objects = getAllPosts()
        
        for object in objects {
            viewContext.delete(object)
        }
        try? viewContext.save()
    }
    
    func batchInsertPosts(_ posts: [PostModel]) {
        guard !posts.isEmpty else { return }
        
        PersistenceController.shared.container.performBackgroundTask { context in
            context.transactionAuthor = "Posts Storage"
            let batchInsert = self.storePosts(posts: posts)
            do {
                try context.execute(batchInsert)
                print("Finished batch inserting \(posts.count) posts")
            } catch {
                let nsError = error as NSError
                print("Error batch inserting posts %@", nsError.userInfo)
            }
        }
    }

    func storePosts(posts: [PostModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = posts.count
        
        let batchInsert = NSBatchInsertRequest(entity: PostCD.entity()) { (managedObject: NSManagedObject) -> Bool in
            
            guard index < total else { return true }
            
            if let post = managedObject as? PostCD {
                let data = posts[index]
                post.timestamp = Date()
                post.postId = Int16(data.postId)
                post.id = Int16(data.id)
                post.name = data.name
                post.email = data.email
                post.body = data.body
            }
            index += 1
            return false
        }
        return batchInsert
    }
}

extension PostStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller:
                                           NSFetchedResultsController<NSFetchRequestResult>) {
        guard let Posts = controller.fetchedObjects as? [PostCD] else { return }
        self.posts.value = Posts
    }
}
