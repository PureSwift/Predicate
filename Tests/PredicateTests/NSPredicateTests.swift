//
//  NSPredicateTests.swift
//  PredicateTests
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import Foundation
import XCTest
@testable import Predicate

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

final class NSPredicateTests: XCTestCase {
    
    func testPredicate1() {
        
        let predicate: Predicate = #keyPath(PersonObject.id) > Int64(0)
            && #keyPath(PersonObject.id) != Int64(99)
            && (#keyPath(PersonObject.name)).compare(.beginsWith, .value(.string("C")))
            && (#keyPath(PersonObject.name)).compare(.contains, [.diacriticInsensitive, .caseInsensitive], .value(.string("COLE")))
        
        let converted = predicate.toFoundation()
        
        print(predicate)
        print(converted)
        
        XCTAssert(predicate.description == converted.description, "Invalid description")
        XCTAssert(converted.evaluate(with: PersonObject(id: 1, name: "Coléman")))
    }
    
    func testPredicate2() {
        
        let identifiers: [Int64] = [1, 2, 3]
        
        let predicate: Predicate = (#keyPath(PersonObject.name)).any(in: ["coleman", "miller"])
            && (#keyPath(PersonObject.id)).any(in: identifiers)
            || (#keyPath(PersonObject.id)).all(in: [Int16]())
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        let test = [PersonObject(id: 1, name: "coleman"), PersonObject(id: 2, name: "miller")]
        XCTAssert(nsPredicate.evaluate(with: test))
    }
    
    func testPredicate3() {
        
        let identifiers: [Int64] = [1, 2, 3]
        let predicate: Predicate = (#keyPath(PersonObject.name)).`in`(["coleman", "miller"]) && (#keyPath(PersonObject.id)).`in`(identifiers)
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        XCTAssert(nsPredicate.evaluate(with: PersonObject(id: 1, name: "coleman")))
        XCTAssert(([PersonObject(id: 1, name: "coleman"), PersonObject(id: 2, name: "miller")] as NSArray).filtered(using: nsPredicate).count == 2)
    }
    
    func testPredicate4() {
        
        let events = [EventObject(id: 100, name: "Awesome Event", start: Date(timeIntervalSince1970: 0), speakers: [PersonObject(id: 1, name: "Alsey Coleman Miller")])]
        
        let now = Date()
        
        let identifiers: [Int64] = [100, 200, 300]
        
        let predicate: Predicate = (#keyPath(EventObject.name)).compare(.contains, [.caseInsensitive], .value(.string("event")))
            && (#keyPath(EventObject.name)).`in`(["Awesome Event"])
            && (#keyPath(EventObject.id)).`in`(identifiers)
            && (#keyPath(EventObject.start)) < now
            && (#keyPath(EventObject.speakers.name)).all(in: ["Alsey Coleman Miller"])
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(nsPredicate.evaluate(with: events[0]))
        XCTAssert((events as NSArray).filtered(using: nsPredicate).count == events.count)
    }
    
    func testPredicate5() {
        
        let events = [
            EventObject(
                id: 100,
                name: "Awesome Event",
                start: Date(timeIntervalSince1970: 0),
                speakers: [
                    PersonObject(
                        id: 1,
                        name: "Alsey Coleman Miller"
                    )
            ]),
            EventObject(
                id: 200,
                name: "Second Event",
                start: Date(timeIntervalSince1970: 60 * 60 * 2),
                speakers: [
                    PersonObject(
                        id: 2,
                        name: "John Apple"
                    )
            ])
        ]
        
        let now = Date()
        
        let predicate: Predicate = (#keyPath(EventObject.name)).compare(.matches, [.caseInsensitive], .value(.string(#"\w+ event"#)))
            && (#keyPath(EventObject.start)) < now
            && ((#keyPath(EventObject.speakers.name)).any(in: ["Alsey Coleman Miller"])
            || (#keyPath(EventObject.speakers.name)).compare(.contains, .value(.string("John Apple"))))
            && (#keyPath(EventObject.speakers.name)).any(in: ["Alsey Coleman Miller", "John Apple", "Test"])
            && (#keyPath(EventObject.speakers.name)).all(in: ["John Apple", "Alsey Coleman Miller"])
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssertEqual((events as NSArray).filtered(using: nsPredicate).count, events.count)
    }
}

// MARK: - Supporting Types

@objc(Person)
class PersonObject: NSObject {
    
    @objc var id: Int
    @objc var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        super.init()
    }
}

@objc(Event)
class EventObject: NSObject {
    
    @objc var id: Int
    @objc var name: String
    @objc var start: Date
    @objc var speakers: Set<PersonObject>
    
    init(id: Int, name: String, start: Date, speakers: Set<PersonObject>) {
        self.id = id
        self.name = name
        self.start = start
        self.speakers = speakers
        super.init()
    }
}

#endif
