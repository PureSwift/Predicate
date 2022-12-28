//
//  Expression.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Used to represent expressions in a predicate.
public enum Expression: Equatable, Hashable {
    
    /// Expression that represents a given constant value.
    case value(Value)
    
    /// Expression that invokes `value​For​Key​Path:​` with a given key path.
    case keyPath(PredicateKeyPath)
}

/// Type of predicate expression.
public enum ExpressionType: String, Codable {
    
    case value
    case keyPath
}

public extension Expression {
    
    var type: ExpressionType {
        switch self {
        case .value: return .value
        case .keyPath: return .keyPath
        }
    }
}

// MARK: - CustomStringConvertible

extension Expression: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case let .value(value):    return value.description
        case let .keyPath(value):  return value.description
        }
    }
}

// MARK: - Codable

extension Expression: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case type
        case expression
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ExpressionType.self, forKey: .type)
        
        switch type {
        case .value:
            let expression = try container.decode(Value.self, forKey: .expression)
            self = .value(expression)
        case .keyPath:
            let keyPath = try container.decode(String.self, forKey: .expression)
            self = .keyPath(PredicateKeyPath(rawValue: keyPath))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        switch self {
        case let .value(value):
            try container.encode(value, forKey: .expression)
        case let .keyPath(keyPath):
            try container.encode(keyPath.rawValue, forKey: .expression)
        }
    }
}

// MARK: - Extensions

public extension Expression {
    
    func compare(_ type: Comparison.Operator, _ rhs: Expression) -> Predicate {
        
        let comparison = Comparison(left: self, right: rhs, type: type)
        return .comparison(comparison)
    }
    
    func compare(_ type: Comparison.Operator, _ options: Set<Comparison.Option>, _ rhs: Expression) -> Predicate {
        
        let comparison = Comparison(left: self, right: rhs, type: type, options: options)
        return .comparison(comparison)
    }
    
    func compare(_ modifier: Comparison.Modifier, _ type: Comparison.Operator, _ options: Set<Comparison.Option>, _ rhs: Expression) -> Predicate {
        
        let comparison = Comparison(left: self, right: rhs, type: type, modifier: modifier, options: options)
        return .comparison(comparison)
    }
}

#if swift(>=5.5)

extension Expression: Sendable {}
extension ExpressionType: Sendable {}

#endif
