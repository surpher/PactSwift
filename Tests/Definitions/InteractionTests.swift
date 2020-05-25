//
//  InteractionTests.swift
//  PactSwift
//
//  Created by Marko Justinek on 26/5/20.
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

class InteractionTests: XCTestCase {

	var sut: Interaction!

	func testConvenienceInit_WithDescription() {
		sut = Interaction(description: "A test request")
		XCTAssertEqual(sut.description, "A test request")
	}

	func testGivenState_WithArray() {
		sut = Interaction(description: "A test request with array of states")
		let providerState = ProviderState(description: "array exists", params: ["foo": "bar"])
		let sutWithInteraction = sut.given([providerState])

		XCTAssertEqual(sutWithInteraction.providerStates, [providerState])
		XCTAssertEqual(sutWithInteraction.providerStates?.count, 1)
	}

	func testGivenState_WithVariadicParameter() {
		sut = Interaction(description: "A test request with states as variadic param")
		let oneProviderState = ProviderState(description: "array exists", params: ["foo": "bar"])
		let twoProviderState = ProviderState(description: "variadic exists", params: ["bar": "baz"])
		let sutWithInteraction = sut.given(oneProviderState, twoProviderState)

		do {
			let providerStates = try XCTUnwrap(sutWithInteraction.providerStates)
			XCTAssertEqual(providerStates.count, 2)
			XCTAssertTrue(providerStates.contains(oneProviderState))
			XCTAssertTrue(providerStates.contains(twoProviderState))
		} catch {
			XCTFail("Expected providerStates.")
		}
	}

}
