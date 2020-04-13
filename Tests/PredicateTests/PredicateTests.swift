//
//  PredicateTests.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/20.
//

import Foundation
import XCTest
@testable import Predicate

final class PredicateTests: XCTestCase {
    
    func testDescription() {
        
        XCTAssertEqual(Predicate.comparison(.init(left: .keyPath("name"), right: .value(.string("Coleman")))).description, "name = \"Coleman\"")
    }
}
