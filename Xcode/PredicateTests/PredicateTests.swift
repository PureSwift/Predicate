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
        
        let predicate: Predicate = .value(true) && .value(true) || .value(nil)
        
        print(predicate)
    }
}
