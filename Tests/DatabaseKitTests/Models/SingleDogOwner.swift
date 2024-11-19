//
//  Owner.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-19.
//

import SwiftData
import Foundation
import DatabaseKit

struct SingleDogOwner: Sendable, Hashable, Equatable {
    var name: String
    var dog: Dog?
    
    var dataModel: SingleDogOwnserDataModel {
        .init(
            name: self.name,
            dog: self.dog?.dataModel
        )
    }
    
    enum Descriptors {
        static func by(name: String) -> FetchDescriptor<SingleDogOwner.SingleDogOwnserDataModel> {
            .init(predicate: #Predicate {
                $0.name == name
            })
        }
    }
    
    @Model
    final class SingleDogOwnserDataModel: PersistableModel {
        var name: String
        var dog: Dog.DogDataModel?
        
        init(
            name: String,
            dog: Dog.DogDataModel? = nil
        ) {
            self.name = name
            self.dog = dog
        }
        
        func toDTO() -> any Sendable {
            if let dog {
                return SingleDogOwner(
                    name: self.name,
                    dog: Dog(model: dog)
                )
            } else {
                return SingleDogOwner(name: self.name)
            }
        }
    }
}
