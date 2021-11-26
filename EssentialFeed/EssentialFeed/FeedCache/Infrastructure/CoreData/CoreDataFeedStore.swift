//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 08.11.2021.
//

import CoreData

public final class CoreDataFeedStore: FeedStoreProtocol {
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL url: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", url: url, in: bundle)
        context = container.newBackgroundContext()
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        perform { context in
            do {
                if let cache = try ManagedCache.find(in: context) {
                    completion(.success(CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)))
                } else {
                    completion(.success((.none)))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                let isCacheEmpty = try ManagedCache.find(in: context) == nil
                let error = NSPersistentContainer.DeletionError.cacheHasNotBeenDeleted
                completion(isCacheEmpty ? nil : error)
            } catch {
                completion(error)
            }
        }
    }
    
    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
