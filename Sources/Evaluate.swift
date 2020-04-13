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
        case (.equalTo, .null, .null):
            return true
        case (.notEqualTo, .null, .null):
            return false
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
            let expressionOptions = NSRegularExpression.Options(options.compactMap({ NSRegularExpression.Options($0) }))
            let regularExpression = try NSRegularExpression(pattern: rhs, options: expressionOptions)
            return regularExpression.numberOfMatches(in: lhs, range: NSRangeFromString(lhs)) > 0
        case let (.beginsWith, .string(lhs), .string(rhs)):
            return lhs.begins(with: rhs)
        case let (.endsWith, .string(lhs), .string(rhs)):
            return lhs.ends(with: rhs)
        case let (.in, .string(lhs), .collection(rhs)):
            let modifier = modifier ?? .any
            switch modifier {
            case .any:
                return rhs.contains(.string(lhs))
            case .all:
                return rhs.contains(where: { $0 != .string(lhs) }) == false
            }
        case let (.contains, .string(lhs), .string(rhs)):
            // FIXME: Case sensitive, locale, diacritic
            return lhs.contains(rhs)
        
        default:
            throw PredicateError.invalidComparison(self, other, comparisonOperator, modifier, options)
            
            /*
        case let (.string(lhs), .string(rhs)):
            switch comparisonOperator {
            case .lessThan:
                return lhs.compare
            case .lessThanOrEqualTo      = "<="
            case .greaterThan            = ">"
            case .greaterThanOrEqualTo   = ">="
            case .equalTo                = "="
            case .notEqualTo             = "!="
            case .matches                = "MATCHES"
            case .like                   = "LIKE"
            case .beginsWith             = "BEGINSWITH"
            case .endsWith               = "ENDSWITH"
            case .in                     = "IN"
            case .contains               = "CONTAINS"
            case .between                = "BETWEEN"
            }
        */
        }
    }
}

internal extension NSRegularExpression.Options {
    
    init?(_ option: Comparison.Option) {
        switch option {
        case .caseInsensitive:
            self = .caseInsensitive
        default:
            return nil
        }
    }
}

internal extension String.CompareOptions {
    
    init?(_ option: Comparison.Option) {
        switch option {
        case .caseInsensitive:
            self = .caseInsensitive
        case .diacriticInsensitive:
            self = .diacriticInsensitive
        case .normalized,
             .localeSensitive:
            return nil
        }
    }
}

internal extension String {
    
    func compare(_ other: String, _ options: Set<Comparison.Option>, _ locale: Locale?, _ valid: ComparisonResult...) -> Bool {
        
        let locale = options.contains(.localeSensitive) ? locale : nil
        let compareOptions = CompareOptions(options.compactMap { CompareOptions($0) })
        let result = compare(other, options: compareOptions, range: nil, locale: locale)
        return valid.contains(result)
    }
}
