import Testing
import SwiftData
import Foundation

@testable import DatabaseKit

@Suite("Database Tests")
struct DatabaseTests {
    private func makeDatabase() throws -> Database {
        let testContainer = try ModelContainer(
            for: Dog.DogDataModel.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        return Database(container: testContainer)
    }
    
    @Test
    func canPersistModel() async throws {
        let lola = Dog(name: "Lola")
        
        let db = try makeDatabase()
        
        try #require(try await db.create(model: lola.dataModel))
    }
    
    @Test
    func canPersistMultipleModels() async throws {
        let lola = Dog(name: "Lola")
        let rawlie = Dog(name: "Rawlie")
        
        let db = try makeDatabase()
        
        try #require(try await db.create(model: lola.dataModel))
        try #require(try await db.create(model: rawlie.dataModel))
        
        let allFetchedDogs: [Dog] = try await db.fetch(
            Dog.Descriptors.allDogs()
        )
        
        try #require(allFetchedDogs.count == 2)
        let allFetchedDogsNames = allFetchedDogs.map({ $0.name })
        try #require(allFetchedDogsNames.contains(lola.name))
        try #require(allFetchedDogsNames.contains(rawlie.name))
    }
    
    @Test
    func canFetchModel() async throws {
        let lola = Dog(name: "Lola")
        
        let db = try makeDatabase()
        
        try #require(try await db.create(model: lola.dataModel))
        
        let allFetchedDogs: [Dog] = try await db.fetch(
            Dog.Descriptors.allDogs()
        )
        
        try #require(allFetchedDogs.count == 1)
        let fetchedDog = try #require(allFetchedDogs.first)
        try #require(fetchedDog.name == lola.name)
    }
    
    @Test
    func canFetchByName() async throws {
        let lola = Dog(name: "Lola")
        
        let db = try makeDatabase()
        
        try #require(try await db.create(model: lola.dataModel))
        
        let fetchedDogs: [Dog] = try await db.fetch(
            Dog.Descriptors.by(name: lola.name)
        )
        
        try #require(fetchedDogs.count == 1)
        let firstFetchedDog = try #require(fetchedDogs.first)
        try #require(firstFetchedDog.name == lola.name)
    }
    
    @Test func canFetchMultipleSortedByName() async throws {
        let lola = Dog(name: "Lola")
        let rawlie = Dog(name: "Rawlie")
        let kawi = Dog(name: "Kawi")
        
        let db = try makeDatabase()
        
        try #require(try await db.create(model: lola.dataModel))
        try #require(try await db.create(model: rawlie.dataModel))
        try #require(try await db.create(model: kawi.dataModel))
        
        let fetchedDogs: [Dog] = try await db.fetch(
            Dog.Descriptors.sortedBy(.name())
        )
        try #require(fetchedDogs.map({ $0.name }) == [kawi.name, lola.name, rawlie.name])
    }
}
