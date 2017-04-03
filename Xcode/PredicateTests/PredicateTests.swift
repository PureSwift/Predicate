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
    
    func testExample() {
        
        class Foo: NSObject {
            var id: Int
            var name: String
            init(id: Int, name: String) {
                self.id = id
                self.name = name
                super.init()
            }
        }
        
        let predicate: Predicate = #keyPath(Foo.id) > Int(0)
            && #keyPath(Foo.id) != Int(99)
             && (#keyPath(Foo.name)).compare(.contains, [.caseInsensitive], "Cole")
            && (#keyPath(Foo.name)).compare(.like, "Coleman")
        
        print(predicate)
    }
}
