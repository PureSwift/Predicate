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
    
    func testStringComparison() {
        
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("Coleman"), operator: .equalTo)))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("test"), operator: .notEqualTo)))
        XCTAssertNoThrow(XCTAssertEqual(try Value.string("b").compare(.string("a"), operator: .lessThan), ("b" < "a")))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("Cole"), operator: .beginsWith)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.string("Coleman").compare(.string("ole"), operator: .beginsWith)))
        //XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("cole"), operator: .beginsWith, options: [.caseInsensitive])))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .endsWith)))
        XCTAssertNoThrow(XCTAssertFalse(try Value.string("Coleman").compare(.string("Cole"), operator: .endsWith)))
        XCTAssertNoThrow(XCTAssert(try Value.string("Coleman").compare(.string("man"), operator: .contains)))
        
    }
}
