//
//  Predicate.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

public protocol PredicateProtocol: Equatable, CustomStringConvertible { }

/// You use predicates to represent logical conditions, used for describing objects in persistent stores and in-memory filtering of objects.
public enum Predicate: PredicateProtocol {
    
    case comparison(Comparision)
    case compound(Compound)
}

// MARK: - Equatable

public func == (lhs: Predicate, rhs: Predicate) -> Bool {
    
    switch (lhs, rhs) {
    case let (.comparison(lhsValue), .comparison(rhsValue)): return lhsValue == rhsValue
    case let (.compound(lhsValue), .compound(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

// MARK: - CustomStringConvertible

public extension Predicate {
    
    var description: String {
        
        switch self {
        case let .comparison(predicate):    return predicate.description
        case let .compound(predicate):      return predicate.description
        }
    }
}

// MARK: - Evaluate

/// Protocol for types that can be evaluated with a predicate.
public protocol PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool
}

extension Sequence where Iterator.Element: PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool {
        
        for element in self {
            
            guard try element.evaluate(with: predicate)
                else { return false }
        }
        
        return true
    }
}
