//
//  RelationshipTests.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-19.
//

import Testing
import SwiftData

@testable import DatabaseKit

@Suite("Relationship Tests")
struct Test {
    private func makeDatabase() throws -> Database {
        let testContainer = try ModelContainer(
            for: Dog.DogDataModel.self, SingleDogOwner.SingleDogOwnserDataModel.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        return Database(container: testContainer)
    }
    
    @Test func canCreateAndFetchModelsWithRelationship() async throws {
        let db = try makeDatabase()
        
        let rawlie = Dog(name: "Rawlie")
        let steven = SingleDogOwner(
            name: "Steven",
            dog: rawlie
        )
        
        try await db.create(model: rawlie.dataModel)
        try await db.create(model: steven.dataModel)
        
        let fetchedDog: [Dog] = try await db.fetch(Dog.Descriptors.allDogs())
        let firstFetchedDog = try #require(fetchedDog.first)
        try #require(firstFetchedDog.name == rawlie.name)
        
        let fetchedOwners: [SingleDogOwner] = try await db.fetch(SingleDogOwner.Descriptors.by(name: "Steven"))
        let firstFetchedOwner = try #require(fetchedOwners.first)
        try #require(firstFetchedOwner.name == steven.name)
        try #require(firstFetchedOwner.dog?.name == rawlie.name)
    }
}
