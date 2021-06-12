//
//  SwiveTests.swift
//  SwiveTests
//
//  Created by Jonas Mårtensson on 2021-06-09.
//

import XCTest
@testable import Swive

class SwiveTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testEntryCoding() throws {
       let json = """
       {
           "name": "root",
           "type": "d",
           "subentries": []
       }
       """

       let data = Data( Array(json.utf8) );

       let entry = Entry(
           name: "root",
           type: .Directory
       )
       
       let encoded = try? JSONEncoder().encode(entry)

       let decoded_from_data = try? JSONDecoder().decode(Entry.self, from: data)
       let decoded_from_enc  = try? JSONDecoder().decode(Entry.self, from: encoded!)

       XCTAssertEqual(entry, decoded_from_data)
       XCTAssertEqual(entry, decoded_from_enc)
    }
    
}
