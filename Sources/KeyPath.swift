//
//  KeyPath.swift
//  
//
//  Created by Alsey Coleman Miller on 4/13/20.
//

/// Key Path
public struct PredicateKeyPath: Equatable, Hashable {
    
    public var keys: [Key]
    
    public init(keys: [Key]) {
        self.keys = keys
    }
}

// MARK: - CustomStringConvertible

extension PredicateKeyPath: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

// MARK: - RawRepresentable

extension PredicateKeyPath: RawRepresentable {
    
    public init(rawValue: String) {
        let components = rawValue.split(separator: ".")
        let keys: [Key] = components.map { UInt($0).flatMap({ .index($0) }) ?? .property(String($0)) }
        self.init(keys: keys)
    }
    
    public var rawValue: String {
        return keys.reduce("", { $0 + "\($0.isEmpty ? "" : ".")" + $1.description })
    }
}

// MARK: - ExpressibleByStringLiteral

extension PredicateKeyPath: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: - ExpressibleByArrayLiteral

extension PredicateKeyPath: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Key...) {
        self.init(keys: elements)
    }
}

// MARK: - Supporting Types

// MARK: - Key

public extension PredicateKeyPath {
    
    enum Key: Equatable, Hashable {
        case property(String)
        case index(UInt)
    }
}

// MARK: CustomStringConvertible

extension PredicateKeyPath.Key: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .property(key): return key
        case let .index(index): return index.description
        }
    }
}
