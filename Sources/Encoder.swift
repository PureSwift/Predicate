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
                
        private(set) var values: [String: Value]
        
        // MARK: - Initialization
        
        init(codingPath: [CodingKey] = [],
             userInfo: [CodingUserInfoKey : Any],
             log: ((String) -> ())?) {
            
            self.values = [:]
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.log = log
        }
        
        // MARK: - Encoder
        
        func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
            
            log?("Requested container keyed by \(type.sanitizedName) for path \"\(codingPath.path)\"")
            let keyedContainer = PredicateKeyedContainer<Key>(referencing: self)
            return KeyedEncodingContainer(keyedContainer)
        }
        
        func unkeyedContainer() -> UnkeyedEncodingContainer {
            
            log?("Requested unkeyed container for path \"\(codingPath.path)\"")
            return PredicateUnkeyedEncodingContainer(referencing: self)
        }
        
        func singleValueContainer() -> SingleValueEncodingContainer {
            
            log?("Requested single value container for path \"\(codingPath.path)\"")
            return PredicateSingleValueEncodingContainer(referencing: self)
        }
    }
}


internal extension PredicateEncoder.Encoder {
    
    func write(_ value: Value, for keyPath: String) {
        values[keyPath] = value
        log?("Did encode \(value.type) value for keyPath \"\(keyPath)\"")
    }
    
    func writeEncodable <T: Encodable> (_ value: T, for keyPath: String) throws {
        
        if let data = value as? Data {
            write(.data(data), for: keyPath)
        } else if let uuid = value as? UUID {
            write(.uuid(uuid), for: keyPath)
        } else if let date = value as? Date {
            write(.date(date), for: keyPath)
        } else {
            // encode using Encodable, container should write directly.
            try value.encode(to: self)
        }
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
    
    // MARK: - Initialization
    
    init(referencing encoder: PredicateEncoder.Encoder) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }
    
    // MARK: - Methods
    
    func encodeNil(forKey key: K) throws {
        encode(.null, for: key)
    }
    
    func encode(_ value: Bool, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: Int, forKey key: K) throws {
        encode(Int64(value), for: key)
    }
    
    func encode(_ value: Int8, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: Int16, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: Int32, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: Int64, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: UInt, forKey key: K) throws {
        encode(UInt64(value), for: key)
    }
    
    func encode(_ value: UInt8, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: UInt16, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: UInt32, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: UInt64, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: Float, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: Double, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode(_ value: String, forKey key: K) throws {
        encode(value, for: key)
    }
    
    func encode <T: Encodable> (_ value: T, forKey key: K) throws {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let keyPath = encoder.codingPath.path
        try encoder.writeEncodable(value, for: keyPath)
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
    
    private func encode<T: PredicateValue>(_ value: T, for key: K) {
        encode(value.predicateValue, for: key)
    }
    
    private func encode(_ value: Value, for key: K) {
        
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        let keyPath = encoder.codingPath.path
        encoder.write(value, for: keyPath)
    }
}

// MARK: - SingleValueEncodingContainer

internal final class PredicateSingleValueEncodingContainer: SingleValueEncodingContainer {
    
    // MARK: - Properties
    
    /// A reference to the encoder we're writing to.
    let encoder: PredicateEncoder.Encoder
    
    /// The path of coding keys taken to get to this point in encoding.
    let codingPath: [CodingKey]
    
    /// Whether the data has been written
    private var didWrite = false
    
    let keyPath: String
    
    // MARK: - Initialization
    
    init(referencing encoder: PredicateEncoder.Encoder) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
        self.keyPath = encoder.codingPath.path
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
    
    func encode <T: Encodable> (_ value: T) throws {
        precondition(didWrite == false, "Data already written")
        encoder.writeEncodable(<#T##value: Encodable##Encodable#>, for: <#T##String#>)
        didWrite = true
    }
    
    // MARK: - Private Methods
    
    private func encode<T: PredicateValue>(_ value: T) {
        encode(value.predicateValue)
    }
    
    private func encode(_ value: Value) {
        precondition(didWrite == false, "Data already written")
        encoder.write(value, for: keyPath)
        didWrite = true
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
