//
//  Expression.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Used to represent expressions in a predicate.
public enum Expression {
    
    /// Expression that represents a given constant value.
    case value(Value)
    
    /// Expression that invokes `value​For​Key​Path:​` with a given key path.
    case keyPath(String)
}

// MARK: - Equatable

extension Expression: Equatable {
    
    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        
        switch (lhs, rhs) {
        case let (.keyPath(lhsValue), .keyPath(rhsValue)): return lhsValue == rhsValue
        case let (.value(lhsValue), .value(rhsValue)): return lhsValue == rhsValue
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Expression: CustomStringConvertible {
    
    /// A textual representation of this instance.
    ///
    /// Instead of accessing this property directly, convert an instance of any
    /// type to a string by using the `String(describing:)` initializer. For
    /// example:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String {
        
        switch self {
        case let .value(value):    return "\(value)"
        case let .keyPath(value):  return "\(value)"
        }
    }
}
