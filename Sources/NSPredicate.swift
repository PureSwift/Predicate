//
//  NSPredicate.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import Foundation

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

public extension Predicate {
    
    func toFoundation() -> NSPredicate {
        
        switch self {
        case let .compound(predicate): return predicate.toFoundation()
        case let .comparison(predicate): return predicate.toFoundation()
        case let .value(value): return NSPredicate(value: value)
        }
    }
}

public extension Compound {
    
    func toFoundation() -> NSCompoundPredicate {
        
        let subpredicates = self.subpredicates.map { $0.toFoundation() }
        return NSCompoundPredicate(type: type.toFoundation(), subpredicates: subpredicates)
    }
}

public extension Compound.Logical​Type {
    
    func toFoundation() -> NSCompoundPredicate.LogicalType {
        switch self {
        case .and: return .and
        case .or: return .or
        case .not: return .not
        }
    }
}

public extension Comparision {
    
    func toFoundation() -> NSComparisonPredicate {
        
        let options = self.options.reduce(NSComparisonPredicate.Options(), { $0.union($1.toFoundation()) })
        return NSComparisonPredicate(leftExpression: left.toFoundation(),
                                     rightExpression: right.toFoundation(),
                                     modifier: modifier?.toFoundation() ?? .direct,
                                     type: type.toFoundation(),
                                     options: options)
    }
}

public extension Comparision.Modifier {
    
    func toFoundation() -> NSComparisonPredicate.Modifier {
        
        switch self {
        case .all: return .all
        case .any: return .any
        }
    }
}

public extension Comparision.Operator {
    
    func toFoundation() -> NSComparisonPredicate.Operator {
        
        switch self {
        case .lessThan:             return .lessThan
        case .lessThanOrEqualTo:    return .lessThanOrEqualTo
        case .greaterThan:          return .greaterThan
        case .greaterThanOrEqualTo: return .greaterThanOrEqualTo
        case .equalTo:              return .equalTo
        case .notEqualTo:           return .notEqualTo
        case .matches:              return .matches
        case .like:                 return .like
        case .beginsWith:           return .beginsWith
        case .endsWith:             return .endsWith
        case .`in`:                 return .`in`
        case .contains:             return .contains
        case .between:              return .between
        }
    }
}

public extension Comparision.Option {
    
    func toFoundation() -> NSComparisonPredicate.Options {
        
        /// `NSLocale​Sensitive​Predicate​Option` is not availible in Swift for some reason.
        /// Lack of Swift annotation it seems.
        
        switch self {
        case .caseInsensitive: return .caseInsensitive
        case .diacriticInsensitive: return .diacriticInsensitive
        case .normalized: return .normalized
        case .localeSensitive: return NSComparisonPredicate.Options(rawValue: 0x08)
        }
    }
}

public extension Expression {
    
    func toFoundation() -> NSExpression {
        
        switch self {
        case let .keyPath(keyPath): return NSExpression(forKeyPath: keyPath)
        case let .value(value): return NSExpression(forConstantValue: value.toFoundation())
        }
    }
}

public extension Value {
    
    func toFoundation() -> AnyObject? {
        
        switch self {
        case .null: return nil
        case let .string(value):    return value as NSString
        case let .data(value):      return value as NSData
        case let .date(value):      return value as NSDate
        case let .uuid(value):      return value as NSUUID
        case let .bool(value):      return value as NSNumber
        case let .int8(value):      return value as NSNumber
        case let .int16(value):     return value as NSNumber
        case let .int32(value):     return value as NSNumber
        case let .int64(value):     return value as NSNumber
        case let .uint8(value):     return value as NSNumber
        case let .uint16(value):     return value as NSNumber
        case let .uint32(value):     return value as NSNumber
        case let .uint64(value):     return value as NSNumber
        case let .float(value):     return value as NSNumber
        case let .double(value):    return value as NSNumber
        case let .collection(value): return value.map({ $0.toFoundation() }) as NSArray
        }
    }
}

#endif
