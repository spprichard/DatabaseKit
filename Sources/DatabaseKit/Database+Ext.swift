//
//  Database+Ext.swift
//  DatabaseKit
//
//  Created by Steven Prichard on 2024-11-19.
//

import SwiftData

extension Database {
    public enum Event: Sendable {
        public enum Transactions: Sendable {
            case updated([DefaultHistoryTransaction])
        }

        case transactions(Transactions)
    }
}
