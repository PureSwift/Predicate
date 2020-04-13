//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/13/20.
//

import Foundation

/// Context for evaluating predicates.
public struct PredicateContext: Equatable, Hashable {
    
    public typealias KeyPath = PredicateKeyPath
    
    public var locale: Locale?
    
    public var values: [KeyPath: Value]
    
    public init(values: [KeyPath: Value],
                locale: Locale? = nil) {
        
        self.values = values
        self.locale = locale
    }
    
    public subscript(keyPath: KeyPath) -> Value? {
        return values[keyPath]
    }
}

extension PredicateContext: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (PredicateKeyPath, Value)...) {
        self.init(values: [PredicateKeyPath: Value](uniqueKeysWithValues: elements))
    }
}

internal extension PredicateContext {
    
    func value(for expression: Expression) throws -> Value {
        switch expression {
        case let .value(value):
            return value
        case let .keyPath(keyPath):
            if let value = self[keyPath] {
                return value
            } else {
                let arrayPath = keyPath.removingLast()
                let paths = values.filter { $0.key.begins(with: arrayPath) }
                
                throw PredicateError.invalidKeyPath(keyPath)
            }
        }
    }
}

extension PredicateContext: PredicateEvaluatable {
    
    public func evaluate(with predicate: Predicate) throws -> Bool {
        
        switch predicate {
        case let .value(value):
            return value
        case let .comparison(comparison):
            return try evaluate(with: comparison)
        case let .compound(compound):
            return try evaluate(with: compound)
        }
    }
    
    internal func evaluate(with predicate: Comparison) throws -> Bool {
        
        let lhs = try value(for: predicate.left)
        let rhs = try value(for: predicate.right)
        return try lhs.compare(rhs, operator: predicate.type, modifier: predicate.modifier, options: predicate.options)
    }
}
