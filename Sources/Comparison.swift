//
//  Comparison.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

public struct Comparision {
    
    public var expression: (left: Expression, right: Expression)
    
    public var type: Operator
    
    public var modifier: Modifier?
    
    public var options: [Option]
    
    init(expression: (left: Expression, right: Expression),
         type: Operator = .equalTo,
         modifier: Modifier? = nil,
         options: [Option] = []) {
        
        self.expression = expression
        self.type = type
        self.modifier = modifier
        self.options = options
    }
}

// MARK: - Supporting Types

public extension Comparision {

    public enum Modifier: String {
        
        case all        = "ANY"
        case any        = "ALL"
    }
    
    public enum Option: String {
        
        case caseInsensitive        = "[c]"
        case diacriticInsensitive   = "[d]"
        case normalized             = "[n]"
        case localeSensitive        = "[l]"
    }
    
    public enum Operator: String {
        
        case lessThan               = "<"
        case lessThanOrEqualTo      = "<="
        case greaterThan            = ">"
        case greaterThanOrEqualTo   = ">="
        case equalTo                = "="
        case notEqualTo             = "!="
        case matches                = "MATCHES"
        case like                   = "LIKE"
        case beginsWith             = "BEGINSWITH"
        case endsWith               = "ENDSWITH"
        case `in`                   = "IN"
        case contains               = "CONTAINS"
        case between                = "BETWEEN"
    }
}

// MARK: - Equatable

extension Comparision: Equatable {
    
    public static func == (lhs: Comparision, rhs: Comparision) -> Bool {
        
        return false
    }
}

// MARK: - CustomStringConvertible

extension Comparision: CustomStringConvertible {
    
    public var description: String {
        
        return "WIP"
    }
}
