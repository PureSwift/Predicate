//
//  Predicate.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// You use predicates to represent logical conditions,
/// used for describing objects in persistent stores and in-memory filtering of objects.
public enum Predicate: Equatable {
    
    case comparison(Comparision)
    case compound(Compound)
    case value(Bool)
}

/// Predicate Type
public enum PredicateType: String, Codable {
    
    case comparison
    case compound
    case value
}

public extension Predicate {
    
    /// Predicate Type
    var type: PredicateType {
        switch self {
        case .comparison: return .comparison
        case .compound: return .compound
        case .value: return .value
        }
    }
}

// MARK: - CustomStringConvertible

extension Predicate: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case let .comparison(value):    return value.description
        case let .compound(value):      return value.description
        case let .value(value):         return value.description
        }
    }
}

// MARK: - Codable

extension Predicate: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case type
        case predicate
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(PredicateType.self, forKey: .type)
        
        switch type {
        case .comparison:
            let predicate = try container.decode(Comparision.self, forKey: .predicate)
            self = .comparison(predicate)
        case .compound:
            let predicate = try container.decode(Compound.self, forKey: .predicate)
            self = .compound(predicate)
        case .value:
            let value = try container.decode(Bool.self, forKey: .predicate)
            self = .value(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        
        switch self {
        case let .comparison(predicate):
            try container.encode(predicate, forKey: .predicate)
        case let .compound(predicate):
            try container.encode(predicate, forKey: .predicate)
        case let .value(value):
            try container.encode(value, forKey: .predicate)
        }
    }
}

// MARK: - Evaluate

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
