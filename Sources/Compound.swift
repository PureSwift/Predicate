//
//  Compound.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Predicate type used to represent logical “gate” operations (AND/OR/NOT) and comparison operations.
public indirect enum Compound: Equatable {
    
    case and([Predicate])
    case or([Predicate])
    case not(Predicate)
}

// MARK: - Accessors

public extension Compound {
    
    public var type: Logical​Type {
        
        switch self {
        case .and:  return .and
        case .or:   return .or
        case .not:  return .not
        }
    }
    
    public var subpredicates: [Predicate] {
        
        switch self {
        case let .and(subpredicates):   return subpredicates
        case let .or(subpredicates):    return subpredicates
        case let .not(subpredicate):    return [subpredicate]
        }
    }
}

// MARK: - Supporting Types

public extension Compound {
    
    /// Possible Compund Predicate types.
    public enum Logical​Type: String, Codable {
        
        /// A logical NOT predicate.
        case not = "NOT"
        
        /// A logical AND predicate.
        case and = "AND"
        
        /// A logical OR predicate.
        case or = "OR"
    }
}

// MARK: - CustomStringConvertible

extension Compound: CustomStringConvertible {
    
    public var description: String {
        
        guard subpredicates.isEmpty == false else {
            
            return "(Empty \(type) predicate)"
        }
        
        var text = ""
        
        for (index, predicate) in subpredicates.enumerated() {
            
            let showType: Bool
            
            if index == 0 {
                
                showType = subpredicates.count == 1
                
            } else {
                
                showType = true
                
                text += " "
            }
            
            if showType {
                
                text += type.rawValue + " "
            }
            
            let includeBrackets: Bool
            
            switch predicate {
            case .compound: includeBrackets = true
            case .comparison, .value: includeBrackets = false
            }
            
            text += includeBrackets ? "(" + predicate.description + ")" : predicate.description
        }
        
        return text
    }
}


// MARK: - Codable

extension Compound: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case type
        case predicates
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(Compound.Logical​Type.self, forKey: .type)
        
        switch type {
        case .and:
            let predicates = try container.decode([Predicate].self, forKey: .predicates)
            self = .and(predicates)
        case .or:
            let predicates = try container.decode([Predicate].self, forKey: .predicates)
            self = .or(predicates)
        case .not:
            let predicate = try container.decode(Predicate.self, forKey: .predicates)
            self = .not(predicate)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        
        switch self {
        case let .and(predicates):
            try container.encode(predicates, forKey: .predicates)
        case let .or(predicates):
            try container.encode(predicates, forKey: .predicates)
        case let .not(predicate):
            try container.encode(predicate, forKey: .predicates)
        }
    }
}

// MARK: - Predicate Operators

public func && (lhs: Predicate, rhs: Predicate) -> Predicate {
    
    return .compound(.and([lhs, rhs]))
}

public func && (lhs: Predicate, rhs: [Predicate]) -> Predicate {
    
    return .compound(.and([lhs] + rhs))
}

public func || (lhs: Predicate, rhs: Predicate) -> Predicate {
    
    return .compound(.or([lhs, rhs]))
}

public func || (lhs: Predicate, rhs: [Predicate]) -> Predicate {
    
    return .compound(.or([lhs] + rhs))
}

public prefix func ! (rhs: Predicate) -> Predicate {
    
    return .compound(.not(rhs))
}
