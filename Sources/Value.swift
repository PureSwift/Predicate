//
//  Value.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import Foundation

/// Constant value used in predicate expressions.
public enum Value: Equatable, Hashable, Sendable {
    
    case null
    case string(String)
    case data(Data)
    case date(Date)
    case uuid(UUID)
    case bool(Bool)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    case float(Float)
    case double(Double)
    case collection([Value])
}

// MARK: - Supporting Types

/// Predicate Value Type
public enum ValueType: String, Codable, Sendable {
    
    case null
    case string
    case data
    case date
    case uuid
    case bool
    case int8
    case int16
    case int32
    case int64
    case uint8
    case uint16
    case uint32
    case uint64
    case float
    case double
    case collection
}

public extension Value {
    
    var type: ValueType {
        
        switch self {
        case .null: return .null
        case .string: return .string
        case .data: return .data
        case .date: return .date
        case .uuid: return .uuid
        case .bool: return .bool
        case .int8: return .int8
        case .int16: return .int16
        case .int32: return .int32
        case .int64: return .int64
        case .uint8: return .uint8
        case .uint16: return .uint16
        case .uint32: return .uint32
        case .uint64: return .uint64
        case .float: return .float
        case .double: return .double
        case .collection: return .collection
        }
    }
}

// MARK: - CustomStringConvertible

extension Value: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case .null:                 return "nil"
        case let .string(value):    return "\"\(value)\""
        case let .data(value):      return value.description
        case let .date(value):      return value.description
        case let .uuid(value):      return value.uuidString
        case let .bool(value):      return value.description
        case let .int8(value):      return value.description
        case let .int16(value):     return value.description
        case let .int32(value):     return value.description
        case let .int64(value):     return value.description
        case let .uint8(value):     return value.description
        case let .uint16(value):     return value.description
        case let .uint32(value):     return value.description
        case let .uint64(value):     return value.description
        case let .float(value):     return value.description
        case let .double(value):    return value.description
        
        case let .collection(values):
            
            var text = "{"
            
            for (index, value) in values.enumerated() {
                
                text += value.description
                
                if index != values.count - 1 {
                    
                    text += ", "
                }
            }
            
            text += "}"
            
            return text
        }
    }
}

// MARK: - Codable

extension Value: Codable {
    
    internal enum CodingKeys: String, CodingKey, Sendable {
        
        case type
        case value
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(ValueType.self, forKey: .type)
        
        switch type {
        case .null:
            self = .null
        case .string:
            let value = try container.decode(String.self, forKey: .value)
            self = .string(value)
        case .data:
            let value = try container.decode(Data.self, forKey: .value)
            self = .data(value)
        case .date:
            let value = try container.decode(Date.self, forKey: .value)
            self = .date(value)
        case .uuid:
            let value = try container.decode(UUID.self, forKey: .value)
            self = .uuid(value)
        case .bool:
            let value = try container.decode(Bool.self, forKey: .value)
            self = .bool(value)
        case .int8:
            let value = try container.decode(Int8.self, forKey: .value)
            self = .int8(value)
        case .int16:
            let value = try container.decode(Int16.self, forKey: .value)
            self = .int16(value)
        case .int32:
            let value = try container.decode(Int32.self, forKey: .value)
            self = .int32(value)
        case .int64:
            let value = try container.decode(Int64.self, forKey: .value)
            self = .int64(value)
        case .uint8:
            let value = try container.decode(UInt8.self, forKey: .value)
            self = .uint8(value)
        case .uint16:
            let value = try container.decode(UInt16.self, forKey: .value)
            self = .uint16(value)
        case .uint32:
            let value = try container.decode(UInt32.self, forKey: .value)
            self = .uint32(value)
        case .uint64:
            let value = try container.decode(UInt64.self, forKey: .value)
            self = .uint64(value)
        case .float:
            let value = try container.decode(Float.self, forKey: .value)
            self = .float(value)
        case .double:
            let value = try container.decode(Double.self, forKey: .value)
            self = .double(value)
        case .collection:
            let value = try container.decode([Value].self, forKey: .value)
            self = .collection(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        
        switch self {
        case .null:
            break // dont encode any value
        case let .string(value):
            try container.encode(value, forKey: .value)
        case let .data(value):
            try container.encode(value, forKey: .value)
        case let .date(value):
            try container.encode(value, forKey: .value)
        case let .uuid(value):
            try container.encode(value, forKey: .value)
        case let .bool(value):
            try container.encode(value, forKey: .value)
        case let .int8(value):
            try container.encode(value, forKey: .value)
        case let .int16(value):
            try container.encode(value, forKey: .value)
        case let .int32(value):
            try container.encode(value, forKey: .value)
        case let .int64(value):
            try container.encode(value, forKey: .value)
        case let .uint8(value):
            try container.encode(value, forKey: .value)
        case let .uint16(value):
            try container.encode(value, forKey: .value)
        case let .uint32(value):
            try container.encode(value, forKey: .value)
        case let .uint64(value):
            try container.encode(value, forKey: .value)
        case let .float(value):
            try container.encode(value, forKey: .value)
        case let .double(value):
            try container.encode(value, forKey: .value)
        case let .collection(value):
            try container.encode(value, forKey: .value)
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

extension UUID: PredicateValue {
    public var predicateValue: Value { return .uuid(self) }
}

extension Bool: PredicateValue {
    public var predicateValue: Value { return .bool(self) }
}

extension Int: PredicateValue {
    public var predicateValue: Value { return .int64(numericCast(self)) }
}

extension UInt: PredicateValue {
    public var predicateValue: Value { return .uint64(numericCast(self)) }
}

extension Int8: PredicateValue {
    public var predicateValue: Value { return .int8(self) }
}

extension Int16: PredicateValue {
    public var predicateValue: Value { return .int16(self) }
}

extension Int32: PredicateValue {
    public var predicateValue: Value { return .int32(self) }
}

extension Int64: PredicateValue {
    public var predicateValue: Value { return .int64(self) }
}

extension UInt8: PredicateValue {
    public var predicateValue: Value { return .uint8(self) }
}

extension UInt16: PredicateValue {
    public var predicateValue: Value { return .uint16(self) }
}

extension UInt32: PredicateValue {
    public var predicateValue: Value { return .uint32(self) }
}

extension UInt64: PredicateValue {
    public var predicateValue: Value { return .uint64(self) }
}

extension Float: PredicateValue {
    public var predicateValue: Value { return .float(self) }
}

extension Double: PredicateValue {
    public var predicateValue: Value { return .double(self) }
}

extension Sequence where Element: PredicateValue {
    public var predicateValue: Value { return .collection(self.map({ $0.predicateValue })) }
}
