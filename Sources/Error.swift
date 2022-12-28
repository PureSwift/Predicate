//
//  Error.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation

public enum PredicateError: Error {
    
    case invalidKeyPath(PredicateKeyPath)
    case invalidComparison(Value, Value, Comparison.Operator, Comparison.Modifier?, Set<Comparison.Option>)
}

#if swift(>=5.5)

extension PredicateError: Sendable {}

#endif
