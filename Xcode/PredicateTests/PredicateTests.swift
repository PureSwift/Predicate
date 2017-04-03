//
//  PredicateTests.swift
//  PredicateTests
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import XCTest
@testable import Predicate

final class PredicateTests: XCTestCase {
    
    class Person: NSObject {
        var id: Int
        var name: String
        init(id: Int, name: String) {
            self.id = id
            self.name = name
            super.init()
        }
    }
    
    class Event: NSObject {
        var id: Int
        var name: String
        var start: Date
        var speakers: Set<Person>
        init(id: Int, name: String, start: Date, speakers: Set<Person>) {
            self.id = id
            self.name = name
            self.start = start
            self.speakers = speakers
            super.init()
        }
    }
    
    func testPredicate1() {
        
        let predicate: Predicate = #keyPath(Person.id) > Int64(0)
            && #keyPath(Person.id) != Int64(99)
            && (#keyPath(Person.name)).compare(.beginsWith, .value(.string("C")))
            && (#keyPath(Person.name)).compare(.contains, [.diacriticInsensitive, .caseInsensitive], .value(.string("COLE")))
        
        let converted = predicate.toFoundation()
        
        print(predicate)
        print(converted)
        
        XCTAssert(predicate.description == converted.description, "Invalid description")
        XCTAssert(converted.evaluate(with: Person(id: 1, name: "Coléman")))
    }
    
    func testPredicate2() {
        
        let identifiers: [Int64] = [1, 2, 3]
        
        let predicate: Predicate = (#keyPath(Person.name)).any(in: ["coleman", "miller"])
            && (#keyPath(Person.id)).any(in: identifiers)
            || (#keyPath(Person.id)).all(in: [Int16]())
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        let test = [Person(id: 1, name: "coleman"), Person(id: 2, name: "miller")]
        XCTAssert(nsPredicate.evaluate(with: test))
    }
    
    func testPredicate3() {
        
        let identifiers: [Int64] = [1, 2, 3]
        
        let predicate: Predicate = (#keyPath(Person.name)).`in`(["coleman", "miller"]) && (#keyPath(Person.id)).`in`(identifiers)
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        XCTAssert(nsPredicate.evaluate(with: Person(id: 1, name: "coleman")))
        XCTAssert(([Person(id: 1, name: "coleman"), Person(id: 2, name: "miller")] as NSArray).filtered(using: nsPredicate).count == 2)
    }
    
    func testPredicate4() {
        
        let events = [Event(id: 100, name: "Awesome Event", start: Date(timeIntervalSince1970: 0), speakers: [Person(id: 1, name: "Alsey Coleman Miller")])]
        
        let now = Date()
        
        let identifiers: [Int64] = [100, 200, 300]
        
        let predicate: Predicate = (#keyPath(Event.name)).compare(.contains, [.caseInsensitive], .value(.string("event")))
            && (#keyPath(Event.name)).`in`(["Awesome Event"])
            && (#keyPath(Event.id)).`in`(identifiers)
            && (#keyPath(Event.start)) < now
            && (#keyPath(Event.speakers.name)).all(in: ["Alsey Coleman Miller"])
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(nsPredicate.evaluate(with: events[0]))
        XCTAssert((events as NSArray).filtered(using: nsPredicate).count == events.count)
    }
}
