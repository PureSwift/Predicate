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

internal extension PredicateEvaluatable {
        
    func evaluate(with predicate: Compound) throws -> Bool {
        
        switch predicate {
        case let .and(subpredicates):
            // all conditions must evaluate to true
            return try subpredicates.contains(where: { try evaluate(with: $0) == false }) == false
        case let .or(subpredicates):
            // one condition must evaluate to true
            return try subpredicates.contains { try evaluate(with: $0) }
        case let .not(subpredicate):
            // must evaluate to false
            return try evaluate(with: subpredicate) == false
        }
    }
}

/// Context for evaluating predicates.
public struct PredicateContext: Equatable, Hashable {
    
    public var locale: Locale?
    
    internal var values: [String: Value]
    
    public init(_ values: [String: Value], locale: Locale? = nil) {
        self.values = values
        self.locale = locale
    }
    
    public subscript(keyPath: String) -> Value? {
        return values[keyPath]
    }
}

extension PredicateContext: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Value)...) {
        self.init([String: Value](uniqueKeysWithValues: elements))
    }
}

internal extension PredicateContext {
    
    func value(for expression: Expression) throws -> Value {
        switch expression {
        case let .value(value):
            return value
        case let .keyPath(keyPath):
            guard let value = self[keyPath]
                else { throw PredicateError.invalidKeyPath(keyPath) }
            return value
        }
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

internal extension Value {
    
    func compare(_ other: Value,
                 operator comparisonOperator: Comparison.Operator,
                 modifier: Comparison.Modifier? = nil,
                 options: Set<Comparison.Option> = [],
                 locale: Locale? = nil) throws -> Bool {
        
        switch (comparisonOperator, self, other) {
        // null
        case (.equalTo, .null, .null):
            return true
        case (.notEqualTo, .null, .null):
            return false
            
        // string
        case (.equalTo, .string, .null):
            return false
        case (.equalTo, .null, .string):
            return false
        case (.notEqualTo, .string, .null):
            return true
        case (.notEqualTo, .null, .string):
            return true
        case let (.lessThan, .string(lhs), .string(rhs)):
            return lhs.compare(rhs, options, locale, .orderedAscending)
        case let (.lessThanOrEqualTo, .string(lhs), .string(rhs)):
            return lhs.compare(rhs, options, locale, .orderedSame, .orderedAscending)
        case let (.greaterThan, .string(lhs), .string(rhs)):
            return lhs.compare(rhs, options, locale, .orderedDescending)
        case let (.greaterThanOrEqualTo, .string(lhs), .string(rhs)):
            return lhs.compare(rhs, options, locale, .orderedSame, .orderedDescending)
        case let (.equalTo, .string(lhs), .string(rhs)):
            return lhs.compare(rhs, options, locale, .orderedSame)
        case let (.notEqualTo, .string(lhs), .string(rhs)):
            return lhs.compare(rhs, options, locale, .orderedSame) == false
        case let (.matches, .string(lhs), .string(rhs)):
            return lhs.matches(rhs, options, locale)
        case let (.beginsWith, .string(lhs), .string(rhs)):
            return lhs.begins(with: rhs, options, locale)
        case let (.endsWith, .string(lhs), .string(rhs)):
            return lhs.ends(with: rhs, options, locale)
        case let (.in, .string(lhs), .string(rhs)):
            return rhs.range(of: lhs, options, locale) != nil
        case let (.contains, .string(lhs), .string(rhs)):
            return lhs.range(of: rhs, options, locale) != nil
        case let (.in, .string(lhs), .collection(rhs)):
            switch modifier ?? .any {
            case .any: return rhs.contains(where: { String($0).flatMap({ lhs.compare($0, options, locale, .orderedSame) }) ?? false })
            case .all: return rhs.contains(where: { String($0).flatMap({ lhs.compare($0, options, locale, .orderedAscending, .orderedDescending) }) ?? true }) == false
            }
        case let (.contains, .collection(lhs), .string(rhs)):
            switch modifier ?? .any {
            case .any: return lhs.contains(where: { String($0).flatMap({ rhs.compare($0, options, locale, .orderedSame) }) ?? false })
            case .all: return lhs.contains(where: { String($0).flatMap({ rhs.compare($0, options, locale, .orderedAscending, .orderedDescending) }) ?? true }) == false
            }
        
        /// Data
        case (.equalTo, .data, .null):
            return false
        case (.equalTo, .null, .data):
            return false
        case (.notEqualTo, .data, .null):
            return true
        case (.notEqualTo, .null, .data):
            return true
        case let (.equalTo, .data(lhs), .data(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .data(lhs), .data(rhs)):
            return lhs != rhs
        case let (.in, .uint8(lhs), .data(rhs)):
            switch modifier ?? .any {
            case .any: return rhs.contains(lhs)
            case .all: return rhs.contains(where: { $0 != lhs }) == false
            }
        case let (.contains, .data(lhs), .uint8(rhs)):
            switch modifier ?? .any {
            case .any: return lhs.contains(rhs)
            case .all: return lhs.contains(where: { $0 != rhs }) == false
            }
        
        // Date
        case (.equalTo, .date, .null):
            return false
        case (.equalTo, .null, .date):
            return false
        case (.notEqualTo, .date, .null):
            return true
        case (.notEqualTo, .null, .date):
            return true
        case let (.lessThan, .date(lhs), .date(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .date(lhs), .date(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .date(lhs), .date(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .date(lhs), .date(rhs)):
            return lhs >= rhs
        case let (.equalTo, .date(lhs), .date(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .date(lhs), .date(rhs)):
            return lhs != rhs
            
        // UUID
        case (.equalTo, .uuid, .null):
            return false
        case (.equalTo, .null, .uuid):
            return false
        case (.notEqualTo, .uuid, .null):
            return true
        case (.notEqualTo, .null, .uuid):
            return true
        case let (.equalTo, .uuid(lhs), .uuid(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .uuid(lhs), .uuid(rhs)):
            return lhs != rhs
            
        // Bool
        case (.equalTo, .bool, .null):
            return false
        case (.equalTo, .null, .bool):
            return false
        case (.notEqualTo, .bool, .null):
            return true
        case (.notEqualTo, .null, .bool):
            return true
        case let (.equalTo, .bool(lhs), .bool(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .bool(lhs), .bool(rhs)):
            return lhs != rhs
            
        // numbers
        case (.equalTo, .uint8, .null):
            return false
        case (.equalTo, .null, .uint8):
            return false
        case (.notEqualTo, .uint8, .null):
            return true
        case (.notEqualTo, .null, .uint8):
            return true
        case let (.lessThan, .uint8(lhs), .uint8(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .uint8(lhs), .uint8(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .uint8(lhs), .uint8(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .uint8(lhs), .uint8(rhs)):
            return lhs >= rhs
        case let (.equalTo, .uint8(lhs), .uint8(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .uint8(lhs), .uint8(rhs)):
            return lhs != rhs
            
        case (.equalTo, .uint16, .null):
            return false
        case (.equalTo, .null, .uint16):
            return false
        case (.notEqualTo, .uint16, .null):
            return true
        case (.notEqualTo, .null, .uint16):
            return true
        case let (.lessThan, .uint16(lhs), .uint16(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .uint16(lhs), .uint16(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .uint16(lhs), .uint16(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .uint16(lhs), .uint16(rhs)):
            return lhs >= rhs
        case let (.equalTo, .uint16(lhs), .uint16(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .uint16(lhs), .uint16(rhs)):
            return lhs != rhs
            
        case (.equalTo, .uint32, .null):
            return false
        case (.equalTo, .null, .uint32):
            return false
        case (.notEqualTo, .uint32, .null):
            return true
        case (.notEqualTo, .null, .uint32):
            return true
        case let (.lessThan, .uint32(lhs), .uint32(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .uint32(lhs), .uint32(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .uint32(lhs), .uint32(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .uint32(lhs), .uint32(rhs)):
            return lhs >= rhs
        case let (.equalTo, .uint32(lhs), .uint32(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .uint32(lhs), .uint32(rhs)):
            return lhs != rhs
            
        case (.equalTo, .uint64, .null):
            return false
        case (.equalTo, .null, .uint64):
            return false
        case (.notEqualTo, .uint64, .null):
            return true
        case (.notEqualTo, .null, .uint64):
            return true
        case let (.lessThan, .uint64(lhs), .uint64(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .uint64(lhs), .uint64(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .uint64(lhs), .uint64(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .uint64(lhs), .uint64(rhs)):
            return lhs >= rhs
        case let (.equalTo, .uint64(lhs), .uint64(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .uint64(lhs), .uint64(rhs)):
            return lhs != rhs
            
        case (.equalTo, .int8, .null):
            return false
        case (.equalTo, .null, .int8):
            return false
        case (.notEqualTo, .int8, .null):
            return true
        case (.notEqualTo, .null, .int8):
            return true
        case let (.lessThan, .int8(lhs), .int8(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .int8(lhs), .int8(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .int8(lhs), .int8(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .int8(lhs), .int8(rhs)):
            return lhs >= rhs
        case let (.equalTo, .int8(lhs), .int8(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .int8(lhs), .int8(rhs)):
            return lhs != rhs
            
        case (.equalTo, .int16, .null):
            return false
        case (.equalTo, .null, .int16):
            return false
        case (.notEqualTo, .int16, .null):
            return true
        case (.notEqualTo, .null, .int16):
            return true
        case let (.lessThan, .int16(lhs), .int16(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .int16(lhs), .int16(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .int16(lhs), .int16(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .int16(lhs), .int16(rhs)):
            return lhs >= rhs
        case let (.equalTo, .int16(lhs), .int16(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .int16(lhs), .int16(rhs)):
            return lhs != rhs
            
        case (.equalTo, .int32, .null):
            return false
        case (.equalTo, .null, .int32):
            return false
        case (.notEqualTo, .int32, .null):
            return true
        case (.notEqualTo, .null, .int32):
            return true
        case let (.lessThan, .int32(lhs), .int32(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .int32(lhs), .int32(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .int32(lhs), .int32(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .int32(lhs), .int32(rhs)):
            return lhs >= rhs
        case let (.equalTo, .int32(lhs), .int32(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .int32(lhs), .int32(rhs)):
            return lhs != rhs
            
        case (.equalTo, .int64, .null):
            return false
        case (.equalTo, .null, .int64):
            return false
        case (.notEqualTo, .int64, .null):
            return true
        case (.notEqualTo, .null, .int64):
            return true
        case let (.lessThan, .int64(lhs), .int64(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .int64(lhs), .int64(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .int64(lhs), .int64(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .int64(lhs), .int64(rhs)):
            return lhs >= rhs
        case let (.equalTo, .int64(lhs), .int64(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .int64(lhs), .int64(rhs)):
            return lhs != rhs
            
        case (.equalTo, .float, .null):
            return false
        case (.equalTo, .null, .float):
            return false
        case (.notEqualTo, .float, .null):
            return true
        case (.notEqualTo, .null, .float):
            return true
        case let (.lessThan, .float(lhs), .float(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .float(lhs), .float(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .float(lhs), .float(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .float(lhs), .float(rhs)):
            return lhs >= rhs
        case let (.equalTo, .float(lhs), .float(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .float(lhs), .float(rhs)):
            return lhs != rhs
            
        case (.equalTo, .double, .null):
            return false
        case (.equalTo, .null, .double):
            return false
        case (.notEqualTo, .double, .null):
            return true
        case (.notEqualTo, .null, .double):
            return true
        case let (.lessThan, .double(lhs), .double(rhs)):
            return lhs < rhs
        case let (.lessThanOrEqualTo, .double(lhs), .double(rhs)):
            return lhs <= rhs
        case let (.greaterThan, .double(lhs), .double(rhs)):
            return lhs > rhs
        case let (.greaterThanOrEqualTo, .double(lhs), .double(rhs)):
            return lhs >= rhs
        case let (.equalTo, .double(lhs), .double(rhs)):
            return lhs == rhs
        case let (.notEqualTo, .double(lhs), .double(rhs)):
            return lhs != rhs
            
        // collections
        case let (.in, lhs, .collection(rhs)):
            switch modifier ?? .any {
            case .any: return rhs.contains(lhs)
            case .all: return rhs.contains(where: { $0 != lhs }) == false
            }
        case let (.contains, .collection(lhs), rhs):
            switch modifier ?? .any {
            case .any: return lhs.contains(rhs)
            case .all: return lhs.contains(where: { $0 != rhs }) == false
            }
            
        // compare numbers
        default:
            if let lhs = NSNumber(value: self),
                let rhs = NSNumber(value: other) {
                let result = lhs.compare(rhs)
                switch comparisonOperator {
                case .lessThan:
                    return result == .orderedAscending
                case .lessThanOrEqualTo:
                    return result == .orderedAscending || result == .orderedSame
                case .greaterThan:
                    return result == .orderedDescending
                case .greaterThanOrEqualTo:
                    return result == .orderedDescending || result == .orderedSame
                case .equalTo:
                    return result == .orderedSame
                case .notEqualTo:
                    return result != .orderedSame
                default:
                    throw PredicateError.invalidComparison(self, other, comparisonOperator, modifier, options)
                }
            } else {
                throw PredicateError.invalidComparison(self, other, comparisonOperator, modifier, options)
            }
        }
    }
}

