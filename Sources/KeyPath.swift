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

public extension PredicateKeyPath {
    
    @discardableResult
    mutating func removeFirst() -> Key {
        return keys.removeFirst()
    }
    
    func removingFirst() -> PredicateKeyPath {
        var path = self
        path.removeFirst()
        return path
    }
    
    @discardableResult
    mutating func removeLast() -> Key {
        return keys.removeLast()
    }
    
    func removingLast() -> PredicateKeyPath {
        var path = self
        path.removeLast()
        return path
    }
}

internal extension PredicateKeyPath {
    
    func begins(with other: PredicateKeyPath) -> Bool {
        return keys.begins(with: other.keys)
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
        case `operator`(Operator)
    }
}

// MARK: CustomStringConvertible

extension PredicateKeyPath.Key: CustomStringConvertible {
    
    public var description: String {
        return rawValue
    }
}

// MARK: RawRepresentable

extension PredicateKeyPath.Key: RawRepresentable {
    
    public init(rawValue: String) {
        if let index = UInt(rawValue) {
            self = .index(index)
        } else if rawValue.count >= 2,
            rawValue.begins(with: PredicateKeyPath.Operator.prefix),
            let operatorValue = PredicateKeyPath.Operator(rawValue: String(rawValue.suffix(from: rawValue.index(rawValue.startIndex, offsetBy: 1)))) {
            self = .operator(operatorValue)
        } else {
            self = .property(rawValue)
        }
    }
    
    public var rawValue: String {
        switch self {
        case let .property(key):
            return key
        case let .index(index):
            return index.description
        case let .operator(operatorValue):
            return operatorValue.description
        }
    }
}

// MARK: - Operator

public extension PredicateKeyPath {
    
    enum Operator: String {
        case count      = "@count"
        case sum        = "@sum"
        case min        = "@min"
        case max        = "@max"
        case average    = "@avg"
    }
}

internal extension PredicateKeyPath.Operator {
    
    static let prefix = "@"
}

// MARK: CustomStringConvertible

extension PredicateKeyPath.Operator: CustomStringConvertible {
    
    public var description: String {
        return type(of: self).prefix + rawValue
    }
}
