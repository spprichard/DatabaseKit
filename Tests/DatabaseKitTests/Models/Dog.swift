//
//  Dog.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-19.
//

import SwiftData
import Foundation
import DatabaseKit

struct Dog: Sendable, Equatable, Hashable {
    enum Descriptors {
        static func allDogs() -> FetchDescriptor<Dog.DogDataModel> { .init() }
        static func by(name: String) -> FetchDescriptor<Dog.DogDataModel> {
            .init(predicate: #Predicate {
                $0.name == name
            })
        }
        static func sortedBy(_ sort: SortedBy) -> FetchDescriptor<Dog.DogDataModel> {
            switch sort {
            case .name(let sortOrder):
                return .init(
                    sortBy: [
                        SortDescriptor(\.name, order: sortOrder)
                    ]
                )
            }
        }
    }
    
    enum SortedBy {
        case name(sortOrder: SortOrder = .forward)
    }
    
    let id: UUID = .init()
    let name: String
    
    var dataModel: Dog.DogDataModel {
        .init(name: self.name)
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(model: Dog.DogDataModel) {
        self.name = model.name
    }
}

extension Dog {
    @Model
    class DogDataModel: PersistableModel {
        var name: String
        
        init(name: String) {
            self.name = name
        }
        
        func toDTO() -> any Sendable {
            Dog(name: self.name)
        }
    }
}
