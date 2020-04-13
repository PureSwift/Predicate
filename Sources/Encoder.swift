//
//  Encoder.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation

/// Predicate Encoder
internal struct PredicateEncoder {
    
    // MARK: - Properties
    
    /// Any contextual information set by the user for encoding.
    public var userInfo = [CodingUserInfoKey : Any]()
    
    /// Logger handler
    public var log: ((String) -> ())?
    
    // MARK: - Initialization
    
    public init() { }
    
    // MARK: - Methods
    
    public func encode <T: Encodable> (_ value: T) throws -> PredicateContext {
    
        log?("Will encode \(String(reflecting: T.self))")
        
        fatalError()
    }
}

// MARK: - Codable

public extension Encodable {
    
    func evaluate(with predicate: Predicate) throws -> Bool {
        return try evaluate(with: predicate, log: nil)
    }
    
    internal func evaluate(with  predicate: Predicate, log: ((String) -> ())?) throws -> Bool {
        var encoder = PredicateEncoder()
        encoder.log = log
        let context = try encoder.encode(self)
        return try context.evaluate(with: predicate)
    }
}
/*
// MARK: - Encoder

internal extension PredicateEncoder {
    
    final class Encoder: Swift.Encoder {
        
        // MARK: - Properties
        
        /// The path of coding keys taken to get to this point in encoding.
        fileprivate(set) var codingPath: [CodingKey]
        
        /// Any contextual information set by the user for encoding.
        let userInfo: [CodingUserInfoKey : Any]
        
        /// Logger
        let log: ((String) -> ())?
                
        private(set) var stack: Stack
        
        // MARK: - Initialization
        
        init(codingPath: [CodingKey] = [],
             userInfo: [CodingUserInfoKey : Any],
             log: ((String) -> ())?) {
            
            self.stack = Stack()
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.log = log
        }
        
        // MARK: - Encoder
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            
            log?("Requested container keyed by \(type.sanitizedName) for path \"\(codingPath.path)\"")
            
            let stackContainer = KeyedContainer()
            self.stack.push(.keyed(stackContainer))
            
            let keyedContainer = PredicateKeyedContainer<Key>(referencing: self, wrapping: stackContainer)
            
            return KeyedEncodingContainer(keyedContainer)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPath.path)\"")
            
            let stackContainer = UnkeyedContainer()
            self.stack.push(.items(stackContainer))
            
            return PredicateUnkeyedEncodingContainer(referencing: self, wrapping: stackContainer)
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            
            log?("Requested single value container for path \"\(codingPath.path)\"")
            
            let stackContainer = SingleValueContainer()
            self.stack.push(.item(stackContainer))
            
            return PredicateSingleValueEncodingContainer(referencing: self, wrapping: stackContainer)
        }
    }
}


internal extension PredicateEncoder.Encoder {
    
    func boxEncodable <T: Encodable> (_ value: T) throws -> PredicateContext.Property {
        
        if let data = value as? Data {
            return .attribute(.data(data))
        } else if let uuid = value as? UUID {
            return .attribute(.uuid(uuid))
        } else if let date = value as? Date {
            return .attribute(.date(date))
        } else {
            // encode using Encodable, should push new container.
            try value.encode(to: self)
            let nestedContainer = stack.pop()
            switch nestedContainer {
            case let .singleValue(container):
                return container.property
            case let .keyed(container):
                return .relationship(.toOne(PredicateContext(properties: container.properties)))
            case let .unkeyed(container):
                var values = [Value](capacity: container.properties.count)
                var 
                return .relationship(<#T##PredicateContext.Relationship#>)
            }
        }
    }
}

// MARK: - Stack

internal extension PredicateEncoder.Encoder {
    
    struct Stack {
        
        private(set) var containers = [Container]()
        
        fileprivate init() { }
        
        var top: Container {
            guard let container = containers.last
                else { fatalError("Empty container stack.") }
            return container
        }
        
        var root: Container {
            guard let container = containers.first
                else { fatalError("Empty container stack.") }
            return container
        }
        
        mutating func push(_ container: Container) {
            containers.append(container)
        }
        
        @discardableResult
        mutating func pop() -> Container {
            guard let container = containers.popLast()
                else { fatalError("Empty container stack.") }
            return container
        }
    }
}

internal extension PredicateEncoder.Encoder {
    
    final class KeyedContainer {
        
        var properties = [String: PredicateContext.Property]()
        
        init() { }
    }
    
    final class UnkeyedContainer {
        
        var properties = [PredicateContext.Property]()
        
        init() { }
    }
    
    final class SingleValueContainer {
        
        var property: PredicateContext.Property = .attribute(.null)
        
        init() { }
    }
    
    enum Container {
        
        case keyed(KeyedContainer)
        case unkeyed(UnkeyedContainer)
        case singleValue(SingleValueContainer)
    }
}


// MARK: - KeyedEncodingContainerProtocol

internal final class PredicateKeyedContainer <K : CodingKey> : KeyedEncodingContainerProtocol {
    
    typealias Key = K
    
    // MARK: - Properties
    
    /// A reference to the encoder we're writing to.
    let encoder: PredicateEncoder.Encoder
    
    /// The path of coding keys taken to get to this point in encoding.
    let codingPath: [CodingKey]
    
    /// A reference to the container we're writing to.
    let container: PredicateEncoder.Encoder.PropertiesContainer
    
    // MARK: - Initialization
    
    init(referencing encoder: PredicateEncoder.Encoder,
         wrapping container: PredicateEncoder.Encoder.PropertiesContainer) {
        
        self.encoder = encoder
        self.codingPath = encoder.codingPath
        self.container = container
    }
    
    // MARK: - Methods
    
    func encodeNil(forKey key: K) throws {
        // do nothing
    }
    
    func encode(_ value: Bool, forKey key: K) throws {
        try encodePredicate(value, forKey: key)
    }
    
    func encode(_ value: Int, forKey key: K) throws {
        try encodeNumeric(Int32(value), forKey: key)
    }
    
    func encode(_ value: Int8, forKey key: K) throws {
        try encodePredicate(value, forKey: key)
    }
    
    func encode(_ value: Int16, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: Int32, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: Int64, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: UInt, forKey key: K) throws {
        try encodeNumeric(UInt32(value), forKey: key)
    }
    
    func encode(_ value: UInt8, forKey key: K) throws {
        try encodePredicate(value, forKey: key)
    }
    
    func encode(_ value: UInt16, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: UInt32, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: UInt64, forKey key: K) throws {
        try encodeNumeric(value, forKey: key)
    }
    
    func encode(_ value: Float, forKey key: K) throws {
        try encodeNumeric(value.bitPattern, forKey: key)
    }
    
    func encode(_ value: Double, forKey key: K) throws {
        try encodeNumeric(value.bitPattern, forKey: key)
    }
    
    func encode(_ value: String, forKey key: K) throws {
        try encodePredicate(value, forKey: key)
    }
    
    func encode <T: Encodable> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let data = try encoder.boxEncodable(value)
        try setValue(value, data: data, for: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        fatalError()
    }
    
    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        
        fatalError()
    }
    
    func superEncoder() -> Encoder {
        
        fatalError()
    }
    
    func superEncoder(forKey key: K) -> Encoder {
        
        fatalError()
    }
    
    // MARK: - Private Methods
    
    private func encodeNumeric <T: PredicateRawEncodable & FixedWidthInteger> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let data = encoder.boxNumeric(value)
        try setValue(value, data: data, for: key)
    }
    
    private func encodePredicate <T: PredicateRawEncodable> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let data = encoder.box(value)
        try setValue(value, data: data, for: key)
    }
    
    private func setValue <T> (_ value: T, data: Data, for key: Key) throws {
        
        encoder.log?("Will encode value for key \(key.stringValue) at path \"\(encoder.codingPath.path)\"")
        
        let type = try encoder.typeCode(for: key, value: value)
        let item = PredicateItem(type: type, value: data)
        self.container.append(item, options: encoder.options)
    }
}

// MARK: - SingleValueEncodingContainer

internal final class PredicateSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    // MARK: - Properties
    
    /// A reference to the encoder we're writing to.
    let encoder: PredicateEncoder.Encoder
    
    /// The path of coding keys taken to get to this point in encoding.
    let codingPath: [CodingKey]
    
    /// A reference to the container we're writing to.
    let container: PredicateEncoder.Encoder.ItemContainer
    
    /// Whether the data has been written
    private var didWrite = false
    
    // MARK: - Initialization
    
    init(referencing encoder: PredicateEncoder.Encoder,
         wrapping container: PredicateEncoder.Encoder.ItemContainer) {
        
        self.encoder = encoder
        self.codingPath = encoder.codingPath
        self.container = container
    }
    
    // MARK: - Methods
    
    func encodeNil() throws {
        // do nothing
    }
    
    func encode(_ value: Bool) throws { write(encoder.box(value)) }
    
    func encode(_ value: String) throws { write(encoder.box(value)) }
    
    func encode(_ value: Double) throws { write(encoder.boxDouble(value)) }
    
    func encode(_ value: Float) throws { write(encoder.boxFloat(value)) }
    
    func encode(_ value: Int) throws { write(encoder.boxNumeric(Int32(value))) }
    
    func encode(_ value: Int8) throws { write(encoder.box(value)) }
    
    func encode(_ value: Int16) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int32) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int64) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt) throws { write(encoder.boxNumeric(UInt32(value))) }
    
    func encode(_ value: UInt8) throws { write(encoder.box(value)) }
    
    func encode(_ value: UInt16) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt32) throws { write(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt64) throws { write(encoder.boxNumeric(value)) }
    
    func encode <T: Encodable> (_ value: T) throws { write(try encoder.boxEncodable(value)) }
    
    // MARK: - Private Methods
    
    private func write(_ data: Data) {
        
        precondition(didWrite == false, "Data already written")
        self.container.data = data
        self.didWrite = true
    }
}

// MARK: - UnkeyedEncodingContainer

internal final class PredicateUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    // MARK: - Properties
    
    /// A reference to the encoder we're writing to.
    let encoder: PredicateEncoder.Encoder
    
    /// The path of coding keys taken to get to this point in encoding.
    let codingPath: [CodingKey]
    
    /// A reference to the container we're writing to.
    let container: PredicateEncoder.Encoder.ItemsContainer
    
    // MARK: - Initialization
    
    init(referencing encoder: PredicateEncoder.Encoder,
         wrapping container: PredicateEncoder.Encoder.ItemsContainer) {
        
        self.encoder = encoder
        self.codingPath = encoder.codingPath
        self.container = container
    }
    
    // MARK: - Methods
    
    /// The number of elements encoded into the container.
    var count: Int {
        return container.items.count
    }
    
    func encodeNil() throws {
        // do nothing
    }
    
    func encode(_ value: Bool) throws { append(encoder.box(value)) }
    
    func encode(_ value: String) throws { append(encoder.box(value)) }
    
    func encode(_ value: Double) throws { append(encoder.boxNumeric(value.bitPattern)) }
    
    func encode(_ value: Float) throws { append(encoder.boxNumeric(value.bitPattern)) }
    
    func encode(_ value: Int) throws { append(encoder.boxNumeric(Int32(value))) }
    
    func encode(_ value: Int8) throws { append(encoder.box(value)) }
    
    func encode(_ value: Int16) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int32) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: Int64) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt) throws { append(encoder.boxNumeric(UInt32(value))) }
    
    func encode(_ value: UInt8) throws { append(encoder.box(value)) }
    
    func encode(_ value: UInt16) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt32) throws { append(encoder.boxNumeric(value)) }
    
    func encode(_ value: UInt64) throws { append(encoder.boxNumeric(value)) }
    
    func encode <T: Encodable> (_ value: T) throws { append(try encoder.boxEncodable(value)) }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        
        fatalError()
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        
        fatalError()
    }
    
    func superEncoder() -> Encoder {
        
        fatalError()
    }
    
    // MARK: - Private Methods
    
    private func append(_ data: Data) {
        
        let index = PredicateTypeCode(rawValue: UInt8(count)) // current index
        let item = PredicateItem(type: index, value: data)
        
        // write
        self.container.append(item) // already sorted
    }
}
*/
