//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/13/20.
//

import Foundation

/// Context for evaluating predicates.
public struct PredicateContext: Equatable, Hashable, Sendable {
    
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

internal extension PredicateContext {
    
    func value(for expression: Expression) throws -> Value {
        switch expression {
        case let .value(value):
            return value
        case let .keyPath(keyPath):
            if let value = self[keyPath] {
                return value
            } else {
                // try to find collection
                if let values = collection(for: keyPath) {
                    return .collection(values)
                } else {
                    throw PredicateError.invalidKeyPath(keyPath)
                }
            }
        }
    }
}

private extension PredicateContext {
    
    func collection(for keyPath: PredicateKeyPath) -> [Value]? {
        var remainderKeys = [PredicateKeyPath.Key]()
        var keyPath = keyPath
        repeat {
            // try again with smaller keyPath
            defer {
                let lastKey = keyPath.removeLast()
                remainderKeys.append(lastKey)
            }
            let countPath = keyPath.appending(.operator(.count))
            guard let countValue = self[countPath],
                let count = NSNumber(value: countValue)?.uintValue
                else { continue }
            let values = (0 ..< count)
                .map { keyPath.appending(.index($0)).appending(contentsOf: remainderKeys) }
                .compactMap { self[$0] }
            guard values.count == Int(count)
                else { return nil }
            return values
        } while keyPath.keys.isEmpty == false
        return nil
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension PredicateContext: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (PredicateKeyPath, Value)...) {
        self.init(values: [PredicateKeyPath: Value](uniqueKeysWithValues: elements))
    }
}

// MARK: - PredicateEvaluatable

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
