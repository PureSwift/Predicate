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
        XCTAssertNoThrow(try Value.string("test").compare(.string("test"), operator: .in))
    }
    
    func testNull() {
        
        // Null
        XCTAssertNoThrow(XCTAssertTrue(try Value.null.compare(.null, operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.null.compare(.null, operator: .notEqualTo)))
        // String
        XCTAssertNoThrow(XCTAssertFalse(try Value.string("test").compare(.null, operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.string("test").compare(.null, operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.null.compare(.string("test"), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.null.compare(.string("test"), operator: .notEqualTo)))
        // Data
        XCTAssertNoThrow(XCTAssertFalse(try Value.data(Data()).compare(.null, operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.data(Data()).compare(.null, operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.null.compare(.data(Data()), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.null.compare(.data(Data()), operator: .notEqualTo)))
        // Date
        XCTAssertNoThrow(XCTAssertFalse(try Value.date(Date()).compare(.null, operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.date(Date()).compare(.null, operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.null.compare(.date(Date()), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.null.compare(.date(Date()), operator: .notEqualTo)))
        // UUID
        XCTAssertNoThrow(XCTAssertFalse(try Value.uuid(UUID()).compare(.null, operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.uuid(UUID()).compare(.null, operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.null.compare(.uuid(UUID()), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.null.compare(.uuid(UUID()), operator: .notEqualTo)))
        // Bool
        XCTAssertNoThrow(XCTAssertFalse(try Value.bool(false).compare(.null, operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.bool(false).compare(.null, operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.null.compare(.bool(true), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssertTrue(try Value.null.compare(.bool(true), operator: .notEqualTo)))
    }
    
    func testStringComparison() {
        
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("Coleman"), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("test"), operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .lessThan), ("b" < "a")))
        XCTAssertNoThrow(XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .lessThanOrEqualTo), ("b" <= "a")))
        XCTAssertNoThrow(XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .greaterThan), ("b" > "a")))
        XCTAssertNoThrow(XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .greaterThanOrEqualTo), ("b" >= "a")))
        XCTAssertNoThrow(XCTAssert(try Value.string("Fancy a game of Cluedo™?").compare(.string(#"\bClue(do)?™?\b"#), operator: .matches, options: [.caseInsensitive])))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("Cole"), operator: .beginsWith)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.string("Coleman").compare(.string("ole"), operator: .beginsWith)))
        //XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("cole"), operator: .beginsWith, options: [.caseInsensitive])))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .endsWith)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.string("Coleman").compare(.string("Cole"), operator: .endsWith)))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .contains)))
        
    }
}
