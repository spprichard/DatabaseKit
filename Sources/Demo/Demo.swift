//
//  Demo.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-19.
//

import SwiftData
import Foundation
import DatabaseKit

struct Person: Sendable, Equatable, Hashable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    var dataModel: Person.DataModel {
        .init(name: self.name)
    }
    
    enum Descriptors {
        static func all() -> FetchDescriptor<Person.DataModel> { .init() }
        static func by(name: String) -> FetchDescriptor<Person.DataModel>  {
            .init(predicate: #Predicate {
                $0.name == name
            })
        }
    }
    
    /// Currently, the name of this class must be unique. It is used by Swift Data as the table name. At this time there is no way to override the table name SwftData uses 
    @Model
    class DataModel: PersistableModel {
        var name: String
        
        init(name: String) {
            self.name = name
        }
        
        func toDTO() -> any Sendable {
            Person(name: name)
        }
    }
}

@main
struct App {
    static func main() async throws {
        try await fetchExample()
    }
    
    static func fetchExample() async throws {
        let modelContainer = try ModelContainer(
            for: Person.DataModel.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let db = Database(container: modelContainer)
        let developer = Person(name: "Steve")
        
        try await db.create(model: developer.dataModel)
        
        let developerFromDatabase: [Person] = try await db.fetch(Person.Descriptors.by(name: "Steve"))
        if let firstFetchedDeveloper: Person = developerFromDatabase.first {
            print("👍 Fetched \(firstFetchedDeveloper.name) from database")
        } else {
            print("🤔 No developer found in database")
        }
    }
}
