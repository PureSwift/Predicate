//
//  Error.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation

public enum PredicateError: Error, Sendable {
    
    case invalidKeyPath(PredicateKeyPath)
    case invalidComparison(Value, Value, Comparison.Operator, Comparison.Modifier?, Set<Comparison.Option>)
}
