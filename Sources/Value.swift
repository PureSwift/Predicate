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
