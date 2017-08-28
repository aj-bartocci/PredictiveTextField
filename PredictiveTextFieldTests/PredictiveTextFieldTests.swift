//
//  PredictiveTextFieldTests.swift
//  PredictiveTextFieldTests
//
//  Created by AJ Bartocci on 8/23/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import XCTest
@testable import PredictiveTextField

class PredictiveTextFieldTests: XCTestCase {
    
    var sut: PredictiveTextField!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = PredictiveTextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        sut = nil
    }
    
    func test_SettingTextProgrammatically() {
        
        let dataSource = MockSuggestionDataSource(suggestion: "testing")
        sut.predictionDataSource = dataSource
        
        sut.text = "test"
        
        XCTAssertFalse(dataSource.didRequestSuggestion)
    }
    
    func test_textChange_Addition_FromNothing_ToTest() {
        let from = ""
        let to = "test"
        
        let change = sut.textChangeFrom(from, toString: to)
        
        switch change {
        case .added(text: let text):
            XCTAssertEqual(text, to)
            break
        default:
            XCTFail()
            break
        }
    }
    
    func test_textChange_Addition_FromTest_ToTesting() {
        let from = "test"
        let to = "testing"
        
        let change = sut.textChangeFrom(from, toString: to)
        
        switch change {
        case .added(text: let text):
            XCTAssertEqual(text, "ing")
            break
        default:
            XCTFail()
            break
        }
    }
    
    func test_textChange_Addition_RepeatingValue() {
        
        let from = "test"
        let to = "testtest"
        
        // from testing
        // to blah 
        // in this case removal would be testing
        // and addition would be blah
        
        let change = sut.textChangeFrom(from, toString: to)
        
        switch change {
        case .added(text: let text):
            XCTAssertEqual(text, "test")
            break
        default:
            XCTFail()
            break
        }
    }
    
    func test_textChange_Removal_FromTesting_ToTest() {
        let from = "testing"
        let to = "test"
        
        let change = sut.textChangeFrom(from, toString: to)
        
        switch change {
        case .removed(text: let remove, added: let add):
            XCTAssertEqual(remove, "ing")
            XCTAssertNil(add)
            break
        default:
            XCTFail()
            break
        }
    }
    
    func test_textChange_Removal_FromTesting_ToResting() {
        let from = "testing"
        let to = "resting"
        
        let change = sut.textChangeFrom(from, toString: to)
        
        switch change {
        case .removed(text: let remove, added: let add):
            XCTAssertEqual(remove, "testing")
            XCTAssertEqual(add, "resting")
            break
        default:
            XCTFail()
            break
        }
    }
    
    func test_textChange_None_FromTesting_ToTesting() {
        let from = "testing"
        let to = from
        
        let change = sut.textChangeFrom(from, toString: to)
        
        if change != TextChange.none {
            XCTFail()
        }
    }
    
    func test_textFieldShouldChange_FromT_ToTh() {
        
        let dataSource = MockSuggestionDataSource(suggestion: "this is")
        sut.predictionDataSource = dataSource
        
        sut.userText = "t"
        sut.text = sut.userText
        let range = NSRange(location: 1, length: 1)
        
        _ = sut.textField(sut, shouldChangeCharactersIn: range, replacementString: "h")
        
        XCTAssertEqual(sut.userText, "th")
        XCTAssertEqual(sut.text, "this is")
    }
    
    func test_textFieldShouldChange_FromT_ToTe() {
        let dataSource = MockSuggestionDataSource(suggestion: nil)
        sut.predictionDataSource = dataSource
        
        sut.userText = "t"
        sut.text = sut.userText
        let range = NSRange(location: 1, length: 1)
        
        _ = sut.textField(sut, shouldChangeCharactersIn: range, replacementString: "e")
        
        XCTAssertEqual(sut.userText, "te")
        XCTAssertEqual(sut.text, "te")
    }
    
    func test_textFieldShouldChange_FromTe_Backspaced() {
        
        sut.userText = "te"
        sut.text = sut.userText
        let range = NSRange(location: 1, length: 1)
        _ = sut.textField(sut, shouldChangeCharactersIn: range, replacementString: "")
        
        XCTAssertEqual(sut.userText, "t")
        XCTAssertEqual(sut.text, "t")
    }
    
}

extension PredictiveTextFieldTests {
    
    class MockSuggestionDataSource: PredictiveTextFieldDataSource {
        
        var didRequestSuggestion = false
        var suggestion: String?
        init(suggestion: String?) {
            self.suggestion = suggestion
        }
        
        func predictiveTextField(_ textField: UITextField, suggestionForInput input: String) -> String? {
            didRequestSuggestion = true
            return suggestion
        }
    }
}
