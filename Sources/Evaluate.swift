//
//  Evaluate.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation


/// Protocol for types that can be evaluated with a predicate.
public protocol PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool
}

extension Sequence where Element: PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool {
        
        for element in self {
            guard try element.evaluate(with: predicate)
                else { return false }
        }
        return true
    }
}

/// Context for evaluating predicates.
public struct PredicateContext: Equatable, Hashable {
    
    public var properties: [String: Property]
    
    public init(properties: [String: Property] = [:]) {
        self.properties = properties
    }
}

public extension PredicateContext {
    
    enum Property: Equatable, Hashable {
        
        case attribute(Value)
        case relationship(Relationship)
    }
    
    enum Relationship: Equatable, Hashable {
        
        case toOne(PredicateContext)
        case toMany([PredicateContext])
    }
}

// MARK: - PredicateEvaluatable

extension PredicateContext: PredicateEvaluatable {
    
    public func evaluate(with predicate: Predicate) throws -> Bool {
        
        fatalError()
    }
    
    internal func evaluate(with predicate: Comparison) throws -> Bool {
        
        fatalError()
    }
}
