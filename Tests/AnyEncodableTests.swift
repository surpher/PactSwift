//
//  AnyEncodableTests.swift
//  PactSwiftTests
//
//  Created by Marko Justinek on 7/4/20.
//  Copyright © 2020 PACT Foundation. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest

@testable import PactSwift

class AnyEncodableTests: XCTestCase {

	func testEncodableWrapper_Handles_StringValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": "Bar"]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertEqual(testResult, #"{"Foo":"Bar"}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_IntegerValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": 123]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertEqual(testResult, #"{"Foo":123}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_DoubleValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": Double(123.45)]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertEqual(testResult, #"{"Foo":123.45}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_DecimalValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": Decimal(string: "123.45")]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertEqual(testResult, #"{"Foo":123.45}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_BoolValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": true]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertEqual(testResult, #"{"Foo":true}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_ArrayOfStringsValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": ["Bar", "Baz"]]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertEqual(testResult, #"{"Foo":["Bar","Baz"]}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_ArrayOfDoublesValue() {
		do {
			let anyEncodedObject = try PactBuilder(with: ["Foo": [Double(123.45), Double(789.23)]]).encoded(for: .body).node
			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))
			XCTAssertTrue(testResult.contains("789.23")) // NOT THE RIGHT WAY TO TEST THIS! But it will do for now.
			XCTAssertTrue(testResult.contains(#"{"Foo":[123."#))
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_DictionaryValue() {
		do {
			let anyEncodedObject =  try PactBuilder(with: ["Foo": ["Bar": "Baz"]]).encoded(for: .body).node
			let testResult = try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!"))
			XCTAssertEqual(String(data: testResult, encoding: .utf8), #"{"Foo":{"Bar":"Baz"}}"#)
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	func testEncodableWrapper_Handles_EmbeddedSafeJSONValues() {
		do {
			let anyEncodedObject = try PactBuilder(
				with: [
					"Foo": 1,
					"Bar": 1.23,
					"Baz": ["Hello", "World"],
					"Goo": [
						"one": [1, 23.45],
						"two": true
					]
				]
			).encoded(for: .body).node

			let testResult = try XCTUnwrap(String(data: try JSONEncoder().encode(try XCTUnwrap(anyEncodedObject, "Oh noez!")), encoding: .utf8))

			// WARNING: - This is not the greatest way to test this! But it will do for now.
			// AnyEncodable `Request.body` is tested in `PactTests.swift` and handles this test on another level
			XCTAssertTrue(testResult.contains(#""Foo":1"#))
			XCTAssertTrue(testResult.contains(#""Bar":1.23"#))
			XCTAssertTrue(testResult.contains(#""Baz":["Hello","World"]"#))
			XCTAssertTrue(testResult.contains(#""Goo":{"#))
			XCTAssertTrue(testResult.contains(#""one":[1,23.4"#))
			XCTAssertTrue(testResult.contains(#""two":true"#))
		} catch {
			XCTFail("Failed to unwrap or encode `anEncodedObject` into a `String`")
		}
	}

	// MARK: - Testing throws

	func testEncodableWrapper_Handles_InvalidInput() {
		struct FailingTestModel {
			let unsupportedDate = Date()
		}

		do {
			_ = try PactBuilder(with: FailingTestModel()).encoded(for: .body).node
			XCTFail("Expected the EncodableWrapper to throw!")
		} catch {
			do {
				let testResult = try XCTUnwrap(error as? PactBuilder.EncodingError)
				XCTAssertTrue(testResult.localizedDescription.contains("unsupportedDate"))
			} catch {
				XCTFail("Expected an EncodableWrapper.EncodingError to be thrown")
			}
		}
	}

	func testEncodableWrapper_Handles_InvalidArrayInput() {
		let testDate = Date()
		let testDateString = dateComponents(from: testDate)

		struct FailingTestModel {
			let failingArray: Array<Date>

			init(array: [Date]) {
				self.failingArray = array
			}
		}

		let testableObject = FailingTestModel(array: [testDate])

		do {
			_ = try PactBuilder(with: testableObject.failingArray).encoded(for: .body).node
			XCTFail("Expected the EncodableWrapper to throw!")
		} catch {
			do {
				let testResult = try XCTUnwrap(error as? PactBuilder.EncodingError)
				XCTAssertTrue(testResult.localizedDescription.contains("Error casting \'[\(testDateString) "))
			} catch {
				XCTFail("Expected an EncodableWrapper.EncodingError to be thrown")
			}
		}
	}

	func testEncodableWrapper_Handles_InvalidDictInput() {
		struct FailingTestModel {
			let failingDict = ["foo": Date()]
		}

		let testableObject = FailingTestModel()

		do {
			_ = try PactBuilder(with: testableObject.failingDict).encoded(for: .body).node
			XCTFail("Expected the EncodableWrapper to throw!")
		} catch {
			do {
				let testResult = try XCTUnwrap(error as? PactBuilder.EncodingError)
				XCTAssertTrue(testResult.localizedDescription.contains("Error casting \'[\"foo\":"))
			} catch {
				XCTFail("Expected an EncodableWrapper.EncodingError to be thrown")
			}
		}
	}

}

private extension AnyEncodableTests {

	func dateComponents(from date: Date = Date()) -> String {
		let format = DateFormatter()
		format.dateFormat = "yyyy-MM-dd"
		format.timeZone = TimeZone(identifier: "GMT")
		return format.string(from: date)
	}

}
