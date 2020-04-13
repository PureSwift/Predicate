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
    
    func testComparison1() {
        
        let predicate: Predicate = "id" > Int64(0)
            && "id" != Int64(99)
            && "name".compare(.beginsWith, .value(.string("C")))
            && "name".compare(.contains, [.diacriticInsensitive, .caseInsensitive], .value(.string("COLE")))
        
        XCTAssertEqual(predicate.description, #"((id > 0 AND id != 99) AND name BEGINSWITH "C") AND name CONTAINS[cd] "COLE""#)
        
        XCTAssert(try Person(id: 1, name: "Coléman").evaluate(with: predicate, log: { print("Encoder: \($0)") }))
    }
}

// MARK: - Supporting Types

internal extension PredicateTests {
    
    struct ID: RawRepresentable, Equatable, Hashable, Codable {
        
        public let rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
    
    struct Person: Equatable, Hashable, Codable {
        
        var id: ID
        var name: String
        
        init(id: ID, name: String) {
            self.id = id
            self.name = name
        }
    }

    struct Event: Equatable, Hashable, Codable {
        
        var id: ID
        var name: String
        var start: Date
        var speakers: [Person]
        
        init(id: ID, name: String, start: Date, speakers: [Person]) {
            self.id = id
            self.name = name
            self.start = start
            self.speakers = speakers
        }
    }
}

extension PredicateTests.ID: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt) {
        self.init(rawValue: value)
    }
}
