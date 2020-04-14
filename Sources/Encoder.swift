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
        let encoder = Encoder(userInfo: userInfo, log: log)
        try value.encode(to: encoder)
        return PredicateContext(values: encoder.values)
    }
}

// MARK: - Codable

public extension Encodable where Self: PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool {
        return try evaluate(with: predicate, log: nil)
    }
    
    internal func evaluate(with  predicate: Predicate, log: ((String) -> ())?) throws -> Bool {
        let context = try PredicateContext(value: self, log: log)
        return try context.evaluate(with: predicate)
    }
}

public extension PredicateContext {
    
    init<T>(value: T) throws where T: Encodable {
        try self.init(value: value, log: nil)
    }
    
    internal init<T>(value: T, log: ((String) -> ())?) throws where T: Encodable {
        var encoder = PredicateEncoder()
        encoder.log = log
        self = try encoder.encode(value)
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
                
        private(set) var values: [PredicateKeyPath: Value]
        
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
    
    var keyPath: PredicateKeyPath {
        let keys: [PredicateKeyPath.Key] = codingPath.map { (key) in
            if let indexKey = key as? IndexCodingKey {
                return .index(UInt(indexKey.index))
            } else {
                return .property(key.stringValue)
            }
        }
        return PredicateContext.KeyPath(keys: keys)
    }
    
    func write(_ value: Value) {
        let keyPath = self.keyPath
        assert(keyPath.description == codingPath.path)
        values[keyPath] = value
        log?("Did encode \(value.type) value for keyPath \"\(keyPath)\"")
    }
    
    func writeEncodable <T: Encodable> (_ value: T) throws {
        
        if let data = value as? Data {
            write(.data(data))
        } else if let uuid = value as? UUID {
            write(.uuid(uuid))
        } else if let date = value as? Date {
            write(.date(date))
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
        try encoder.writeEncodable(value)
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
        self.encoder.write(value)
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
    
    // MARK: - Initialization
    
    init(referencing encoder: PredicateEncoder.Encoder) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }
    
    // MARK: - Methods
    
    func encodeNil() throws { write(.null) }
    
    func encode(_ value: Bool) throws { write(value) }
    
    func encode(_ value: String) throws { write(value) }
    
    func encode(_ value: Double) throws { write(value) }
    
    func encode(_ value: Float) throws { write(value) }
    
    func encode(_ value: Int) throws { write(Int64(value)) }
    
    func encode(_ value: Int8) throws { write(value) }
    
    func encode(_ value: Int16) throws { write(value) }
    
    func encode(_ value: Int32) throws { write(value) }
    
    func encode(_ value: Int64) throws { write(value) }
    
    func encode(_ value: UInt) throws { write(UInt64(value)) }
    
    func encode(_ value: UInt8) throws { write(value) }
    
    func encode(_ value: UInt16) throws { write(value) }
    
    func encode(_ value: UInt32) throws { write(value) }
    
    func encode(_ value: UInt64) throws { write(value) }
    
    func encode <T: Encodable> (_ value: T) throws {
        precondition(didWrite == false, "Data already written")
        try encoder.writeEncodable(value)
        didWrite = true
    }
    
    // MARK: - Private Methods
    
    private func write<T: PredicateValue>(_ value: T) {
        write(value.predicateValue)
    }
    
    private func write(_ value: Value) {
        precondition(didWrite == false, "Data already written")
        encoder.write(value)
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
    
    // MARK: - Initialization
    
    deinit {
        // write array operators
        
        // count
        self.encoder.codingPath.append(OperatorCodingKey(operatorValue: .count))
        encoder.write(.uint64(UInt64(count)))
        self.encoder.codingPath.removeLast()
    }
    
    init(referencing encoder: PredicateEncoder.Encoder) {
        self.encoder = encoder
        self.codingPath = encoder.codingPath
    }
    
    // MARK: - Methods
    
    /// The number of elements encoded into the container.
    private(set) var count: Int = 0
    
    func encodeNil() throws { append(.null) }
    
    func encode(_ value: Bool) throws { append(value) }
    
    func encode(_ value: String) throws { append(value) }
    
    func encode(_ value: Double) throws { append(value) }
    
    func encode(_ value: Float) throws { append(value) }
    
    func encode(_ value: Int) throws { append(Int64(value)) }
    
    func encode(_ value: Int8) throws { append(value) }
    
    func encode(_ value: Int16) throws { append(value) }
    
    func encode(_ value: Int32) throws { append(value) }
    
    func encode(_ value: Int64) throws { append(value) }
    
    func encode(_ value: UInt) throws { append(UInt64(value)) }
    
    func encode(_ value: UInt8) throws { append(value) }
    
    func encode(_ value: UInt16) throws { append(value) }
    
    func encode(_ value: UInt32) throws { append(value) }
    
    func encode(_ value: UInt64) throws { append(value) }
    
    func encode <T: Encodable> (_ value: T) throws {
        let key = IndexCodingKey(index: count)
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        try encoder.writeEncodable(value)
        count += 1
    }
    
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
    
    private func append<T: PredicateValue>(_ value: T) {
        append(value.predicateValue)
    }
    
    private func append(_ value: Value) {
        let key = IndexCodingKey(index: count)
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        encoder.write(value)
        count += 1
    }
}

internal struct IndexCodingKey: CodingKey, Equatable, Hashable {
    
    let index: Int
    
    init(index: Int) {
        self.index = index
    }
    
    var stringValue: String {
        return index.description
    }
    
    init?(stringValue: String) {
        guard let index = UInt(stringValue)
            else { return nil }
        self.init(index: Int(index))
    }
    
    var intValue: Int? {
        return index
    }
    
    init?(intValue: Int) {
        self.init(index: intValue)
    }
}

internal struct OperatorCodingKey: CodingKey, Equatable, Hashable {
    
    let operatorValue: PredicateKeyPath.Operator
    
    init(operatorValue: PredicateKeyPath.Operator) {
        self.operatorValue = operatorValue
    }
    
    var stringValue: String {
        return operatorValue.rawValue
    }
    
    init?(stringValue: String) {
        guard let operatorValue = PredicateKeyPath.Operator(rawValue: stringValue)
            else { return nil }
        self.init(operatorValue: operatorValue)
    }
    
    var intValue: Int? {
        return nil
    }
    
    init?(intValue: Int) {
        return nil
    }
}
