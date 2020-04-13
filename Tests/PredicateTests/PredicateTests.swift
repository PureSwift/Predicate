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
        XCTAssertEqual(((.keyPath("name") != .value(.null)) as Predicate).description, "name != NULL")
    }
    
    func testPredicate1() {
        
        let predicate: Predicate = "id" > Int64(0)
            && "id" != Int64(99)
            && "name".compare(.beginsWith, .value(.string("C")))
            && "name".compare(.contains, [.diacriticInsensitive, .caseInsensitive], .value(.string("COLE")))
        
        XCTAssertEqual(predicate.description, #"((id > 0 AND id != 99) AND name BEGINSWITH "C") AND name CONTAINS[cd] "COLE""#)
        XCTAssert(try Person(id: 1, name: "Coléman").evaluate(with: predicate, log: { print("Encoder: \($0)") }))
    }
    
    func testPredicate2() {
        
        let identifiers: [Int64] = [1, 2, 3]
        
        let predicate: Predicate = ("name").any(in: ["coleman", "miller"])
            && "id".any(in: identifiers)
            || "id".all(in: [Int16]())
        
        XCTAssertEqual(predicate.description, #"(ANY name IN {"coleman", "miller"} AND ANY id IN {1, 2, 3}) OR ALL id IN {}"#, "Invalid description")
        XCTAssert(try [Person(id: 1, name: "coleman"), Person(id: 2, name: "miller")].filter(with: predicate).count == 2)
    }
    
    func testPredicate3() {
        
        let identifiers: [Int64] = [1, 2, 3]
        let predicate: Predicate = "name".`in`(["coleman", "miller"]) && "id".`in`(identifiers)
        
        XCTAssertEqual(predicate.description, #"name IN {"coleman", "miller"} AND id IN {1, 2, 3}"#, "Invalid description")
        XCTAssert(try Person(id: 1, name: "coleman").evaluate(with: predicate, log: { print("Encoder: \($0)") }))
        XCTAssert(try [Person(id: 1, name: "coleman"), Person(id: 2, name: "miller")].filter(with: predicate).count == 2)
    }
    
    func testPredicate4() {
        
        let now = Date()
        let identifiers: [ID] = [100, 200, 300]
        let events = [
            Event(
                id: identifiers[0],
                name: "Awesome Event",
                start: Date(timeIntervalSince1970: 0),
                speakers: [
                    Person(
                        id: 1,
                        name: "Alsey Coleman Miller"
                    )
            ])
        ]
        
        let predicate: Predicate = "name".compare(.contains, [.caseInsensitive], .value(.string("event")))
            && "name".`in`(["Awesome Event"])
            && "id".`in`(identifiers.map { UInt16($0.rawValue) })
            && "start" < now
            && "speakers.name".all(in: ["Alsey Coleman Miller"])
        
        XCTAssert(try events[0].evaluate(with: predicate, log: { print("Encoder: \($0)") }))
        XCTAssertEqual(try events.filter(with: predicate), events)
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
    
    struct Person: Equatable, Hashable, Codable, PredicateEvaluatable {
        
        var id: ID
        var name: String
        
        init(id: ID, name: String) {
            self.id = id
            self.name = name
        }
    }

    struct Event: Equatable, Hashable, Codable, PredicateEvaluatable {
        
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
