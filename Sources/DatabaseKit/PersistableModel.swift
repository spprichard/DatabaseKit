//
//  PersistableModel.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-19.
//

import SwiftData

public protocol PersistableModel: PersistentModel {
    func toDTO() -> Sendable
}
