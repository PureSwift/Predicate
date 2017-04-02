//
//  Expression.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Used to represent expressions in a predicate.
public enum Expression: PredicateProtocol {
    
    /// Expression that represents a given constant value.
    case value(Any?)
    
    /// Expression that invokes `value​For​Key​Path:​` with a given key path.
    case keyPath(String)
    
    /// The Foundation `NSExpression` object.
    case custom(NSExpression)
    
    /// Aggregate expression for a given collection.
    case aggregate([Any])
    
    /// Expression that represents the union of a given set and collection.
    case union(Expression, Expression)
    
    /// Expression that represents the intersection of a given set and collection.
    case intersection(Expression, Expression)
    
    /// Expression that represents the subtraction of a given collection from a given set.
    case minus(Expression, Expression)
    
    case custom()
}
