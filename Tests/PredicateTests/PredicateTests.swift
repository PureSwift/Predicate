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
    
    static let allTests = [
        ("testDescription", testDescription),
        ("testEncoder", testEncoder),
        ("testPredicate1", testPredicate1),
        ("testPredicate2", testPredicate2),
        ("testPredicate3", testPredicate3),
        ("testPredicate4", testPredicate4),
        ("testPredicate5", testPredicate5),
        ("testPredicate6", testPredicate6),
        ("testPredicate7", testPredicate7)
    ]
    
    func testDescription() {
        
        XCTAssertEqual((.keyPath("name") == .value(.string("Coleman"))).description, "name == \"Coleman\"")
        XCTAssertEqual(((.keyPath("name") != .value(.null)) as Predicate).description, "name != nil")
        XCTAssertEqual((!(.keyPath("name") == .value(.null))).description, "NOT name == nil")
        XCTAssertEqual(("isValid" == false).description, "isValid == false")
    }
    
    func testEncoder() {
        
        let event = Event(
            id: 100,
            name: "Event",
            start: Date(timeIntervalSince1970: 60 * 60 * 2),
            speakers: [
                Person(
                    id: 1,
                    name: "John Apple"
                )
        ])
        
        let context: PredicateContext = [
            "id": .uint64(100),
            "name": .string("Event"),
            "start": .date(Date(timeIntervalSince1970: 60 * 60 * 2)),
            "speakers.@count": .uint64(1),
            "speakers.0.id": .uint64(1),
            "speakers.0.name": .string("John Apple"),
        ]
        XCTAssertEqual(context, try PredicateContext(value: event))
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
        XCTAssert(try [Person(id: 1, name: "test1"), Person(id: 2, name: "test2")].filter(with: predicate).isEmpty)
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
            && "id".`in`(identifiers.map { $0.rawValue })
            && "start" < now
            && "speakers.name".all(in: ["Alsey Coleman Miller"])
        
        XCTAssert(try events[0].evaluate(with: predicate, log: { print("Encoder: \($0)") }))
        XCTAssertEqual(try events.filter(with: predicate), events)
    }
    
    func testPredicate5() {
        
        let events = [
            Event(
                id: 100,
                name: "Awesome Event",
                start: Date(timeIntervalSince1970: 0),
                speakers: [
                    Person(
                        id: 1,
                        name: "Alsey Coleman Miller"
                    )
            ]),
            Event(
                id: 200,
                name: "Second Event",
                start: Date(timeIntervalSince1970: 60 * 60 * 2),
                speakers: [
                    Person(
                        id: 2,
                        name: "John Apple"
                    )
            ])
        ]
        
        let future = Date.distantFuture
        
        let predicate: Predicate = "name".compare(.matches, [.caseInsensitive], .value(.string(#"\w+ event"#)))
            && "start" < future
            && ("speakers.name".any(in: ["Alsey Coleman Miller"])
                || "speakers.name".compare(.contains, .value(.string("John Apple"))))
            && "speakers.name".any(in: ["Alsey Coleman Miller", "John Apple", "Test"])
            && "speakers.name".all(in: ["John Apple", "Alsey Coleman Miller"])
        
        XCTAssertEqual(try events.filter(with: predicate), events)
        XCTAssertEqual(predicate.description, #"(((name MATCHES[c] "\w+ event" AND start < 4001-01-01 00:00:00 +0000) AND (ANY speakers.name IN {"Alsey Coleman Miller"} OR speakers.name CONTAINS "John Apple")) AND ANY speakers.name IN {"Alsey Coleman Miller", "John Apple", "Test"}) AND ALL speakers.name IN {"John Apple", "Alsey Coleman Miller"}"#)
    }
    
    func testPredicate6() {
        
        let events = [
            Event(
                id: 100,
                name: "Awesome Event",
                start: Date(timeIntervalSince1970: 0),
                speakers: [
                    Person(
                        id: 1,
                        name: "Alsey Coleman Miller"
                    )
            ]),
            Event(
                id: 200,
                name: "Second Event",
                start: Date(timeIntervalSince1970: 60 * 60 * 2),
                speakers: [
                    Person(
                        id: 2,
                        name: "John Apple"
                    )
            ])
        ]
        
        let now = Date()
        
        let predicate: Predicate = "name".compare(.matches, [.caseInsensitive], .value(.string(#"\w+ event"#)))
            && "start" < now
            && "speakers.@count" > 0
        
        XCTAssertEqual(try events.filter(with: predicate), events)
    }
    
    func testPredicate7() {
        
        let events = [
            Event(
                id: 1,
                name: "Event 1",
                start: Date(timeIntervalSince1970: 0),
                speakers: [
                    Person(
                        id: 1,
                        name: "Alsey Coleman Miller"
                    )
            ]),
            Event(
                id: 2,
                name: "Event 2",
                start: Date(timeIntervalSince1970: 60 * 60 * 2),
                speakers: [
                    Person(
                        id: 2,
                        name: "John Apple"
                    )
            ]),
            Event(
                id: 3,
                name: "Event 3",
                start: Date(timeIntervalSince1970: 60 * 60 * 4),
                speakers: [
                    Person(
                        id: 1,
                        name: "Alsey Coleman Miller"
                    ),
                    Person(
                        id: 2,
                        name: "John Apple"
                    )
            ])
        ]
        
        let future = Date.distantFuture
        
        let predicate: Predicate = ("name").compare(.matches, [.caseInsensitive], .value(.string(#"event \d"#))) && [
            ("start") < future,
            ("speakers.@count") > 0
            ]
        
        XCTAssertEqual(try events.filter(with: predicate), events)
        XCTAssertEqual(predicate.description, #"name MATCHES[c] "event \d" AND start < 4001-01-01 00:00:00 +0000 AND speakers.@count > 0"#)
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
