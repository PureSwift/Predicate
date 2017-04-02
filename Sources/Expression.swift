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
