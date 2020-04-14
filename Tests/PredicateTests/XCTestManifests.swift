import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(PredicateTests.allTests),
        testCase(ValueTests.allTests),
    ]
}
#endif
