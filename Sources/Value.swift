//
//  Value.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Constant value used in predicate expressions.
public enum Value {
    
    case null
    case string(String)
    case data(Data)
    case date(Date)
    case boolean(Bool)
    case integer(Int)
    case float(Float)
    case double(Double)
}

// MARK: - Equatable

extension Value: Equatable {
    
    public static func == (lhs: Value, rhs: Value) -> Bool {
        
        switch (lhs, rhs) {
        case (.null, .null):                                return true
        case let (.string(lhsValue), .string(rhsValue)):    return lhsValue == rhsValue
        case let (.data(lhsValue), .data(rhsValue)):        return lhsValue == rhsValue
        case let (.date(lhsValue), .date(rhsValue)):        return lhsValue == rhsValue
        case let (.boolean(lhsValue), .boolean(rhsValue)):  return lhsValue == rhsValue
        case let (.integer(lhsValue), .integer(rhsValue)):  return lhsValue == rhsValue
        case let (.float(lhsValue), .float(rhsValue)):      return lhsValue == rhsValue
        case let (.double(lhsValue), .double(rhsValue)):    return lhsValue == rhsValue
        default: return false
        }
    }
}

// MARK: - CustomStringConvertible

extension Value: CustomStringConvertible {
    
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
        case .null:                 return "NULL"
        case let .string(value):    return "\(value)"
        case let .data(value):      return "\(value)"
        case let .date(value):      return "\(value)"
        case let .boolean(value):   return "\(value)"
        case let .integer(value):   return "\(value)"
        case let .float(value):     return "\(value)"
        case let .double(value):    return "\(value)"
        }
    }
}

// MARK: - Supporting Types

public protocol PredicateValue {
    
    var predicateValue: Value { get }
}

extension String: PredicateValue {
    public var predicateValue: Value { return .string(self) }
}

extension Data: PredicateValue {
    public var predicateValue: Value { return .data(self) }
}

extension Date: PredicateValue {
    public var predicateValue: Value { return .date(self) }
}

extension Bool: PredicateValue {
    public var predicateValue: Value { return .boolean(self) }
}

extension Int: PredicateValue {
    public var predicateValue: Value { return .integer(self) }
}

extension Float: PredicateValue {
    public var predicateValue: Value { return .float(self) }
}

extension Double: PredicateValue {
    public var predicateValue: Value { return .double(self) }
}

// MARK: - Predicate Extensions

public extension Predicate {
    
    static func value(_ rawValue: PredicateValue?) -> Predicate {
        
        guard let value = rawValue else { return .expression(.value(.null)) }
        
        return .expression(.value(value.predicateValue))
    }
}
