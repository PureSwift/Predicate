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
        //XCTAssert(try Value.string("Coleman").compare(.string("cole"), operator: .beginsWith, options: [.caseInsensitive])))
        XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .endsWith))
        XCTAssertFalse(try Value.string("Coleman").compare(.string("Cole"), operator: .endsWith))
        XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .contains))
        
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
        
        
    }
}
