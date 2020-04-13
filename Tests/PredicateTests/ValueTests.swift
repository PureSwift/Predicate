//
//  ValueTests.swift
//
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation
import XCTest
@testable import Predicate

final class ValueTests: XCTestCase {
    
    func testInvalid() {
        
        XCTAssertThrowsError(try Value.string("test").compare(.bool(false), operator: .equalTo))
        XCTAssertThrowsError(try Value.data(Data()).compare(.string("test"), operator: .equalTo))
        XCTAssertThrowsError(try Value.bool(true).compare(.string("test"), operator: .in))
        XCTAssertThrowsError(try Value.uint8(0x01).compare(.data(Data([0x01])), operator: .contains))
        XCTAssertThrowsError(try Value.data(Data([0x01])).compare(.uint8(0x01), operator: .in))
        XCTAssertThrowsError(try Value.uint8(0x01).compare(.bool(true), operator: .contains))
    }
    
    func testNull() {
        
        // Null
        XCTAssertTrue(try Value.null.compare(.null, operator: .equalTo))
        XCTAssertFalse(try Value.null.compare(.null, operator: .notEqualTo))
        // String
        XCTAssertFalse(try Value.string("test").compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.string("test").compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.string("test"), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.string("test"), operator: .notEqualTo))
        // Data
        XCTAssertFalse(try Value.data(Data()).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.data(Data()).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.data(Data()), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.data(Data()), operator: .notEqualTo))
        // Date
        XCTAssertFalse(try Value.date(Date()).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.date(Date()).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.date(Date()), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.date(Date()), operator: .notEqualTo))
        // UUID
        XCTAssertFalse(try Value.uuid(UUID()).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.uuid(UUID()).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.uuid(UUID()), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.uuid(UUID()), operator: .notEqualTo))
        // Bool
        XCTAssertFalse(try Value.bool(false).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.bool(false).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.bool(true), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.bool(true), operator: .notEqualTo))
        // UInt8
        XCTAssertFalse(try Value.uint8(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.uint8(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.uint8(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.uint8(0x01), operator: .notEqualTo))
        // UInt16
        XCTAssertFalse(try Value.uint16(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.uint16(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.uint16(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.uint16(0x01), operator: .notEqualTo))
        // UInt32
        XCTAssertFalse(try Value.uint32(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.uint32(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.uint32(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.uint32(0x01), operator: .notEqualTo))
        // UInt64
        XCTAssertFalse(try Value.uint64(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.uint64(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.uint64(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.uint64(0x01), operator: .notEqualTo))
        // Int8
        XCTAssertFalse(try Value.int8(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.int8(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.int8(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.int8(0x01), operator: .notEqualTo))
        // Int16
        XCTAssertFalse(try Value.int16(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.int16(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.int16(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.int16(0x01), operator: .notEqualTo))
        // Int32
        XCTAssertFalse(try Value.int32(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.int32(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.int32(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.int32(0x01), operator: .notEqualTo))
        // Int64
        XCTAssertFalse(try Value.int64(0x01).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.int64(0x01).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.int64(0x01), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.int64(0x01), operator: .notEqualTo))
        // Float
        XCTAssertFalse(try Value.float(1.23).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.float(1.23).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.float(1.23), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.float(1.23), operator: .notEqualTo))
        // Double
        XCTAssertFalse(try Value.double(1.23).compare(.null, operator: .equalTo))
        XCTAssertTrue(try Value.double(1.23).compare(.null, operator: .notEqualTo))
        XCTAssertFalse(try Value.null.compare(.double(1.23), operator: .equalTo))
        XCTAssertTrue(try Value.null.compare(.double(1.23), operator: .notEqualTo))
    }
    
    func testString() {
        
        XCTAssert(try Value.string("Coleman").compare(.string("Coleman"), operator: .equalTo))
        XCTAssert(try Value.string("Coleman").compare(.string("coleman"), operator: .equalTo, options: [.caseInsensitive]))
        XCTAssert(try Value.string("Coleman").compare(.string("test"), operator: .notEqualTo))
        XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .lessThan), ("b" < "a"))
        XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .lessThanOrEqualTo), ("b" <= "a"))
        XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .greaterThan), ("b" > "a"))
        XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .greaterThanOrEqualTo), ("b" >= "a"))
        XCTAssert(try Value.string("Fancy a game of Cluedo™?").compare(.string(#"\bClue(do)?™?\b"#), operator: .matches))
        XCTAssert(try Value.string("Fancy a game of Cluedo™?").compare(.string(#"\bclue(do)?™?\b"#), operator: .matches, options: [.caseInsensitive]))
        XCTAssertFalse(try Value.string("Fancy a game of Cluedo™?").compare(.string(#"\bclue(do)?™?\b"#), operator: .matches))
        XCTAssert(try Value.string("Coleman").compare(.string("Cole"), operator: .beginsWith))
        XCTAssertFalse(try Value.string("Coleman").compare(.string("ole"), operator: .beginsWith))
        XCTAssert(try Value.string("Coleman").compare(.string("cole"), operator: .beginsWith, options: [.caseInsensitive]))
        XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .endsWith))
        XCTAssertFalse(try Value.string("Coleman").compare(.string("Cole"), operator: .endsWith))
        XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .contains))
        XCTAssert(try Value.string("Coleman").compare(.string("cole"), operator: .contains, options: [.caseInsensitive]))
        XCTAssert(try Value.string("man").compare(.string("Coleman"), operator: .in))
        XCTAssert(try Value.string("OLE").compare(.string("Coleman"), operator: .in, options: [.caseInsensitive]))
    }
    
    func testData() {
        
        XCTAssert(try Value.data(Data([0x01])).compare(.data(Data([0x01])), operator: .equalTo))
        XCTAssert(try Value.data(Data([0x01])).compare(.data(Data()), operator: .notEqualTo))
        XCTAssert(try Value.uint8(0x01).compare(.data(Data([0x01])), operator: .in))
        XCTAssert(try Value.uint8(0x01).compare(.data(Data([0x01, 0x01])), operator: .in, modifier: .all))
        XCTAssert(try Value.data(Data([0x01, 0x01])).compare(.uint8(0x01), operator: .contains, modifier: .all))
        XCTAssert(try Value.data(Data([0x01, 0x00])).compare(.uint8(0x01), operator: .contains))
        XCTAssert(try Value.data(Data([0x01, 0x01])).compare(.uint8(0x01), operator: .contains, modifier: .all))
    }
    
    func testDate() {
        
        let date = Date()
        
        XCTAssert(try Value.date(date).compare(.date(date), operator: .equalTo))
        XCTAssert(try Value.date(.distantPast).compare(.date(.distantFuture), operator: .notEqualTo))
        XCTAssert(try Value.date(.distantFuture).compare(.date(date), operator: .notEqualTo))
        XCTAssert(try Value.date(.distantPast).compare(.date(date), operator: .lessThan))
        XCTAssert(try Value.date(.distantPast).compare(.date(date), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.date(.distantPast).compare(.date(.distantPast), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.date(.distantFuture).compare(.date(date), operator: .greaterThan))
        XCTAssert(try Value.date(.distantFuture).compare(.date(date), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.date(.distantFuture).compare(.date(.distantPast), operator: .greaterThanOrEqualTo))
    }
    
    func testUUID() {
        
        let uuid = UUID()
        
        XCTAssert(try Value.uuid(uuid).compare(.uuid(uuid), operator: .equalTo))
        XCTAssertFalse(try Value.uuid(uuid).compare(.uuid(UUID()), operator: .equalTo))
        XCTAssert(try Value.uuid(uuid).compare(.uuid(UUID()), operator: .notEqualTo))
        XCTAssert(try Value.uuid(UUID()).compare(.uuid(uuid), operator: .notEqualTo))
    }
    
    func testCollection() {
        
        let uuid = UUID()
        
        XCTAssert(try Value.string("Coleman").compare(.collection([.string("test"), .string("Coleman")]), operator: .in))
        XCTAssert(try Value.string("Coleman").compare(.collection([.string("Coleman"), .string("Coleman")]), operator: .in, modifier: .all))
        XCTAssert(try Value.collection([.string("test"), .string("Coleman")]).compare(.string("Coleman"), operator: .contains))
        XCTAssert(try Value.collection([.string("Coleman"), .string("Coleman")]).compare(.string("Coleman"), operator: .contains, modifier: .all))
        
        XCTAssert(try Value.string("coleman").compare(.collection([.string("test"), .string("Coleman")]), operator: .in, options: [.caseInsensitive]))
        XCTAssert(try Value.string("coleman").compare(.collection([.string("Coleman"), .string("Coleman")]), operator: .in, modifier: .all, options: [.caseInsensitive]))
        XCTAssert(try Value.collection([.string("test"), .string("Coleman")]).compare(.string("coleman"), operator: .contains, options: [.caseInsensitive]))
        XCTAssert(try Value.collection([.string("Coleman"), .string("Coleman")]).compare(.string("coleman"), operator: .contains, modifier: .all, options: [.caseInsensitive]))
        
        XCTAssert(try Value.uint8(0x01).compare(.collection([.uint8(0x00), .uint8(0x01)]), operator: .in))
        XCTAssertFalse(try Value.uint8(0xFF).compare(.collection([.uint8(0x00), .uint8(0x01)]), operator: .in))
        XCTAssert(try Value.collection([.uint8(0x00), .uint8(0x01)]).compare(.uint8(0x01), operator: .contains))
        XCTAssertFalse(try Value.collection([.uint8(0x00), .uint8(0x01)]).compare(.uint8(0xFF), operator: .contains))
        
        XCTAssert(try Value.uuid(uuid).compare(.collection([.uuid(UUID()), .uuid(uuid)]), operator: .in))
        XCTAssertFalse(try Value.uuid(UUID()).compare(.collection([.uuid(uuid), .uuid(uuid)]), operator: .in))
        XCTAssert(try Value.collection([.uuid(UUID()), .uuid(uuid)]).compare(.uuid(uuid), operator: .contains))
        XCTAssertFalse(try Value.collection([.uuid(UUID()), .uuid(UUID())]).compare(.uuid(UUID()), operator: .contains))
    }
    
    func testNumbers() {
        
        //XCTAssert(try Value.float(1.2).compare(.double(1.20), operator: .equalTo))
        XCTAssert(try Value.float(0.1).compare(.double(1.123), operator: .notEqualTo))
        XCTAssert(try Value.uint8(0x01).compare(.bool(true), operator: .equalTo))
        XCTAssert(try Value.uint8(0x00).compare(.bool(true), operator: .notEqualTo))
        XCTAssert(try Value.bool(true).compare(.uint8(0x01), operator: .equalTo))
        XCTAssert(try Value.bool(false).compare(.uint8(0x01), operator: .notEqualTo))
        XCTAssert(try Value.uint8(0x01).compare(.int8(0x01), operator: .equalTo))
        XCTAssert(try Value.uint8(0x00).compare(.uint16(0x01), operator: .notEqualTo))
        XCTAssert(try Value.uint16(0x1234).compare(.uint32(0x1200), operator: .notEqualTo))
        XCTAssert(try Value.uint16(0x01).compare(.int16(0xAB), operator: .lessThan))
        XCTAssert(try Value.uint32(0x01).compare(.int16(0x01), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int8(-1).compare(.uint16(0xFFFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int64(.max).compare(.int32(.max), operator: .greaterThan))
        XCTAssert(try Value.int32(.max).compare(.int32(.max), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.uint32(.max).compare(.int32(.max), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.bool(true).compare(.bool(true), operator: .equalTo))
        XCTAssert(try Value.bool(false).compare(.bool(false), operator: .equalTo))
        XCTAssertFalse(try Value.bool(true).compare(.bool(true), operator: .notEqualTo))
        XCTAssert(try Value.bool(true).compare(.bool(false), operator: .notEqualTo))
        XCTAssert(try Value.bool(false).compare(.bool(true), operator: .notEqualTo))
        XCTAssertFalse(try Value.bool(true).compare(.bool(true), operator: .notEqualTo))
        
        XCTAssert(try Value.uint8(0xAB).compare(.uint8(0xAB), operator: .equalTo))
        XCTAssert(try Value.uint8(0xAB).compare(.uint8(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.uint8(0x01).compare(.uint8(0x00), operator: .notEqualTo))
        XCTAssert(try Value.uint8(0x01).compare(.uint8(0xFF), operator: .lessThan))
        XCTAssert(try Value.uint8(0x01).compare(.uint8(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint8(0xFF).compare(.uint8(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint8(0xFF).compare(.uint8(0x01), operator: .greaterThan))
        XCTAssert(try Value.uint8(0xFF).compare(.uint8(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.uint8(0x11).compare(.uint8(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.uint16(0xAB).compare(.uint16(0xAB), operator: .equalTo))
        XCTAssert(try Value.uint16(0xAB).compare(.uint16(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.uint16(0x01).compare(.uint16(0x00), operator: .notEqualTo))
        XCTAssert(try Value.uint16(0x01).compare(.uint16(0xFF), operator: .lessThan))
        XCTAssert(try Value.uint16(0x01).compare(.uint16(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint16(0xFF).compare(.uint16(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint16(0xFF).compare(.uint16(0x01), operator: .greaterThan))
        XCTAssert(try Value.uint16(0xFF).compare(.uint16(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.uint16(0x11).compare(.uint16(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.uint32(0xAB).compare(.uint32(0xAB), operator: .equalTo))
        XCTAssert(try Value.uint32(0xAB).compare(.uint32(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.uint32(0x01).compare(.uint32(0x00), operator: .notEqualTo))
        XCTAssert(try Value.uint32(0x01).compare(.uint32(0xFF), operator: .lessThan))
        XCTAssert(try Value.uint32(0x01).compare(.uint32(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint32(0xFF).compare(.uint32(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint32(0xFF).compare(.uint32(0x01), operator: .greaterThan))
        XCTAssert(try Value.uint32(0xFF).compare(.uint32(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.uint32(0x11).compare(.uint32(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.uint64(0xAB).compare(.uint64(0xAB), operator: .equalTo))
        XCTAssert(try Value.uint64(0xAB).compare(.uint64(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.uint64(0x01).compare(.uint64(0x00), operator: .notEqualTo))
        XCTAssert(try Value.uint64(0x01).compare(.uint64(0xFF), operator: .lessThan))
        XCTAssert(try Value.uint64(0x01).compare(.uint64(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint64(0xFF).compare(.uint64(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.uint64(0xFF).compare(.uint64(0x01), operator: .greaterThan))
        XCTAssert(try Value.uint64(0xFF).compare(.uint64(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.uint64(0x11).compare(.uint64(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.int8(0x01).compare(.int8(0x01), operator: .equalTo))
        XCTAssert(try Value.int8(0x01).compare(.int8(0x00), operator: .notEqualTo))
        XCTAssert(try Value.int8(0x01).compare(.int8(0x00), operator: .notEqualTo))
        XCTAssert(try Value.int8(0x01).compare(.int8(.max), operator: .lessThan))
        XCTAssert(try Value.int8(0x01).compare(.int8(.max), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int8(.max).compare(.int8(.max), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int8(.max).compare(.int8(0x01), operator: .greaterThan))
        XCTAssert(try Value.int8(.max).compare(.int8(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.int8(0x11).compare(.int8(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.int16(0xAB).compare(.int16(0xAB), operator: .equalTo))
        XCTAssert(try Value.int16(0xAB).compare(.int16(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.int16(0x01).compare(.int16(0x00), operator: .notEqualTo))
        XCTAssert(try Value.int16(0x01).compare(.int16(.max), operator: .lessThan))
        XCTAssert(try Value.int16(0x01).compare(.int16(.max), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int16(.max).compare(.int16(.max), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int16(.max).compare(.int16(0x01), operator: .greaterThan))
        XCTAssert(try Value.int16(.max).compare(.int16(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.int16(0x11).compare(.int16(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.int32(0xAB).compare(.int32(0xAB), operator: .equalTo))
        XCTAssert(try Value.int32(0xAB).compare(.int32(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.int32(0x01).compare(.int32(0x00), operator: .notEqualTo))
        XCTAssert(try Value.int32(0x01).compare(.int32(0xFF), operator: .lessThan))
        XCTAssert(try Value.int32(0x01).compare(.int32(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int32(0xFF).compare(.int32(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int32(0xFF).compare(.int32(0x01), operator: .greaterThan))
        XCTAssert(try Value.int32(0xFF).compare(.int32(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.int32(0x11).compare(.int32(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.int64(0xAB).compare(.int64(0xAB), operator: .equalTo))
        XCTAssert(try Value.int64(0xAB).compare(.int64(0xCD), operator: .notEqualTo))
        XCTAssert(try Value.int64(0x01).compare(.int64(0x00), operator: .notEqualTo))
        XCTAssert(try Value.int64(0x01).compare(.int64(0xFF), operator: .lessThan))
        XCTAssert(try Value.int64(0x01).compare(.int64(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int64(0xFF).compare(.int64(0xFF), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.int64(0xFF).compare(.int64(0x01), operator: .greaterThan))
        XCTAssert(try Value.int64(0xFF).compare(.int64(0x01), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.int64(0x11).compare(.int64(0x01), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.float(1.23).compare(.float(1.23), operator: .equalTo))
        XCTAssert(try Value.float(1.23).compare(.float(0.12), operator: .notEqualTo))
        XCTAssert(try Value.float(0.12).compare(.float(1.23), operator: .notEqualTo))
        XCTAssert(try Value.float(0.12).compare(.float(1.23), operator: .lessThan))
        XCTAssert(try Value.float(0.12).compare(.float(1.23), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.float(0.12).compare(.float(0.12), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.float(1.23).compare(.float(0.12), operator: .greaterThan))
        XCTAssert(try Value.float(1.23).compare(.float(0.12), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.float(1.23).compare(.float(1.23), operator: .greaterThanOrEqualTo))
        
        XCTAssert(try Value.double(1.23).compare(.double(1.23), operator: .equalTo))
        XCTAssert(try Value.double(1.23).compare(.double(0.12), operator: .notEqualTo))
        XCTAssert(try Value.double(0.12).compare(.double(1.23), operator: .notEqualTo))
        XCTAssert(try Value.double(0.12).compare(.double(1.23), operator: .lessThan))
        XCTAssert(try Value.double(0.12).compare(.double(1.23), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.double(0.12).compare(.double(0.12), operator: .lessThanOrEqualTo))
        XCTAssert(try Value.double(1.23).compare(.double(0.12), operator: .greaterThan))
        XCTAssert(try Value.double(1.23).compare(.double(0.12), operator: .greaterThanOrEqualTo))
        XCTAssert(try Value.double(1.23).compare(.double(1.23), operator: .greaterThanOrEqualTo))
    }
}
