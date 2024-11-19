//
//  Database.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-17.
//

import SwiftData
import Foundation

public actor Database: ModelActor, Sendable {
    private var context: ModelContext { modelExecutor.modelContext }
    private let continuation: AsyncStream<Event>.Continuation
    
    public nonisolated let modelContainer: SwiftData.ModelContainer
    public nonisolated let modelExecutor: any SwiftData.ModelExecutor
    public var history: AsyncStream<Event>
    
    public init(
        container: ModelContainer
    ) {
        self.modelContainer = container
        let modelContext = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        let (stream, continuation) = AsyncStream<Event>.makeStream()
        self.history = stream
        self.continuation = continuation
    }
    
    /// Persists an instance of a PersistentModel to the database.
    /// Will make a best effort to write and pending changes as soon as possible. By doing so, trades off speed for durability.
    /// - Parameter model: The datamodel you wish to save
    public func create<M>(model: M) throws where M: PersistentModel {
        try self._create(model: model)
        notifyChanges()
    }
    
    private func _create<M>(model: M) throws where M: PersistentModel {
        context.insert(model)
        try modelContext.save()
    }
    
    /// Fetched datamodel from database, returning its `Sendable` representation
    /// - Parameter descriptor: The descriptor you wish to fetch by
    /// - Returns: Sendable representation of the underlying datamode
    public func fetch<
        M: PersistableModel,
        D: Sendable
    >( _ descriptor: FetchDescriptor<M>) throws -> [D] {
        let models = try _fetch(descriptor)
        notifyChanges()
        return models.compactMap { $0.toDTO() as? D }
    }

    private func _fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T: PersistentModel {
        return try context
            .fetch(descriptor)
    }

    /// A mechanism for converting a series of database transactions into a sendable representation a model by the provided closure
    /// - Parameters:
    ///   - transactions: A collection of transactions you wish to process
    ///   - transforming: The logic for how to convert the transactions into a collection of `Sendable` datamodels
    /// - Returns: A collection of sendable datamodels 
    public func process<
        M: PersistableModel,
        D: Sendable
    >(
        from transactions: [DefaultHistoryTransaction],
        transforming: @escaping (M) throws -> D
    ) throws -> [D] {
        // TODO: If there are no transactions we could exit early
        var resultingModels: Set<M> = []

        for transaction in transactions {
            for change in transaction.changes {
                let modelID = change.changedPersistentIdentifier
                let fetchDescriptor = FetchDescriptor<M>(predicate: #Predicate {
                    $0.persistentModelID == modelID
                })

                if let matchedModel = try context.fetch(fetchDescriptor).first {
                    switch change {
                    case .insert:
                        resultingModels.insert(matchedModel)
                    case .update:
                        resultingModels.update(with: matchedModel)
                    case .delete:
                        resultingModels.remove(matchedModel)
                    default:
                        continue
                    }
                }
            }
        }

        return resultingModels.compactMap { try? transforming($0) }
    }

    private func fetchTransactions() throws -> [DefaultHistoryTransaction] {
        try context.fetchHistory(.init())
    }
    
    private func notifyChanges() {
        Task {
            await _notifyChanges()
        }
    }
    
    private func _notifyChanges() async {
        do {
            // TODO: This fetches all transactions, should probably be since last token
            let transactions = try fetchTransactions()
            continuation.yield(
                .transactions(.updated(transactions))
            )
        } catch let error {
            print("⚠️ Error fetching transactions: \(error)")
            return
        }
    }
}
