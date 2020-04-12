//
//  Comparison.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Comparison Predicate
public struct Comparison: Equatable, Hashable, Codable {
    
    public var left: Expression
    
    public var right: Expression
    
    public var type: Operator
    
    public var modifier: Modifier?
    
    public var options: Set<Option>
    
    public init(left: Expression,
                right: Expression,
                type: Operator = .equalTo,
                modifier: Modifier? = nil,
                options: Set<Option> = []) {
        
        self.left = left
        self.right = right
        self.type = type
        self.modifier = modifier
        self.options = options
    }
}

// MARK: - Supporting Types

public extension Comparison {

    enum Modifier: String, Codable {
        
        case all        = "ALL"
        case any        = "ANY"
    }
    
    enum Option: String, Codable {
        
        /// A case-insensitive predicate.
        case caseInsensitive        = "c"
        
        /// A diacritic-insensitive predicate.
        case diacriticInsensitive   = "d"
        
        /// Indicates that the strings to be compared have been preprocessed.
        case normalized             = "n"
        
        /// Indicates that strings to be compared using `<`, `<=`, `=`, `=>`, `>`
        /// should be handled in a locale-aware fashion.
        case localeSensitive        = "l"
    }
    
    enum Operator: String, Codable {
        
        case lessThan               = "<"
        case lessThanOrEqualTo      = "<="
        case greaterThan            = ">"
        case greaterThanOrEqualTo   = ">="
        case equalTo                = "="
        case notEqualTo             = "!="
        case matches                = "MATCHES"
        case like                   = "LIKE"
        case beginsWith             = "BEGINSWITH"
        case endsWith               = "ENDSWITH"
        case `in`                   = "IN"
        case contains               = "CONTAINS"
        case between                = "BETWEEN"
    }
}

// MARK: - CustomStringConvertible

extension Comparison: CustomStringConvertible {
    
    public var description: String {
        
        let modifier = self.modifier?.rawValue ?? ""
        
        let leftExpression = "\(self.left)"
        
        let type = self.type.rawValue
        
        let options = self.options.isEmpty ? "" : "[" + self.options
            .sorted(by: { $0.rawValue < $1.rawValue })
            .reduce("") { $0 + $1.rawValue }
            + "]"
        
        let rightExpression = "\(self.right)"
        
        let components = [modifier, leftExpression, type + options, rightExpression]
        
        return components.reduce("") { $0 + "\($0.isEmpty ? "" : " ")" + $1 }
    }
}

// MARK: - Operators

public func < (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparison = Comparison(left: lhs,
                                  right: rhs,
                                  type: .lessThan)
    
    return .comparison(comparison)
}

public func <= (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparison = Comparison(left: lhs,
                                  right: rhs,
                                  type: .lessThanOrEqualTo)
    
    return .comparison(comparison)
}

public func > (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparison = Comparison(left: lhs,
                                  right: rhs,
                                  type: .greaterThan)
    
    return .comparison(comparison)
}

public func >= (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparison = Comparison(left: lhs,
                                  right: rhs,
                                  type: .greaterThanOrEqualTo)
    
    return .comparison(comparison)
}

public func == (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparison = Comparison(left: lhs,
                                  right: rhs,
                                  type: .equalTo)
    
    return .comparison(comparison)
}

public func != (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparison = Comparison(left: lhs,
                                  right: rhs,
                                  type: .notEqualTo)
    
    return .comparison(comparison)
}

// LHS keypath and RHS predicate value

public func < <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparison = Comparison(left: .keyPath(lhs),
                                  right: .value(rhs.predicateValue),
                                  type: .lessThan)
    
    return .comparison(comparison)
}

public func <= <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparison = Comparison(left: .keyPath(lhs),
                                  right: .value(rhs.predicateValue),
                                  type: .lessThanOrEqualTo)
    
    return .comparison(comparison)
}

public func > <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparison = Comparison(left: .keyPath(lhs),
                                  right: .value(rhs.predicateValue),
                                  type: .greaterThan)
    
    return .comparison(comparison)
}

public func >= <T: PredicateValue> (lhs: String, rhs: T) -> Predicate {
    
    let comparison = Comparison(left: .keyPath(lhs),
                                  right: .value(rhs.predicateValue),
                                  type: .greaterThanOrEqualTo)
    
    return .comparison(comparison)
}

public func == <T: PredicateValue> (lhs: String, rhs: T) -> Predicate {
    
    let comparison = Comparison(left: .keyPath(lhs),
                                  right: .value(rhs.predicateValue),
                                  type: .equalTo)
    
    return .comparison(comparison)
}

public func != <T: PredicateValue> (lhs: String, rhs: T) -> Predicate {
    
    let comparison = Comparison(left: .keyPath(lhs),
                                  right: .value(rhs.predicateValue),
                                  type: .notEqualTo)
    
    return .comparison(comparison)
}

// Extensions for KeyPath comparisons
public extension String {
    
    func compare(_ type: Comparison.Operator, _ rhs: Expression) -> Predicate {
        
        let comparison = Comparison(left: .keyPath(self), right: rhs, type: type)
        
        return .comparison(comparison)
    }
    
    func compare(_ type: Comparison.Operator, _ options: Set<Comparison.Option>, _ rhs: Expression) -> Predicate {
        
        let comparison = Comparison(left: .keyPath(self), right: rhs, type: type, options: options)
        
        return .comparison(comparison)
    }
    
    func compare(_ modifier: Comparison.Modifier, _ type: Comparison.Operator, _ options: Set<Comparison.Option>, _ rhs: Expression) -> Predicate {
        
        let comparison = Comparison(left: .keyPath(self), right: rhs, type: type, modifier: modifier, options: options)
        
        return .comparison(comparison)
    }
    
    func any <Value: PredicateValue> (in collection: [Value]) -> Predicate {
        
        let values = collection.map { $0.predicateValue }
        
        let rightExpression = Expression.value(.collection(values))
        
        let comparison = Comparison(left: .keyPath(self), right: rightExpression, type: .`in`, modifier: .any)
        
        return .comparison(comparison)
    }
    
    func all <Value: PredicateValue> (in collection: [Value]) -> Predicate {
        
        let values = collection.map { $0.predicateValue }
        
        let rightExpression = Expression.value(.collection(values))
        
        let comparison = Comparison(left: .keyPath(self), right: rightExpression, type: .`in`, modifier: .all)
        
        return .comparison(comparison)
    }
    
    func `in` <Value: PredicateValue> (_ collection: [Value], options: Set<Comparison.Option> = []) -> Predicate {
        
        let values = collection.map { $0.predicateValue }
        
        let rightExpression = Expression.value(.collection(values))
        
        let comparison = Comparison(left: .keyPath(self), right: rightExpression, type: .`in`, options: options)
        
        return .comparison(comparison)
    }
}
