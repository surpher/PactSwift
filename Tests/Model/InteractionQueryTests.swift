//
//  Created by Oliver Jones on 10/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

import XCTest
@testable import PactSwift

final class InteractionQueryTests: InteractionTestCase {

    // MARK: - Tests

    func testQueryParamWithValue() async throws {
        try builder
            .uponReceiving("an interaction with item value")
            .withRequest(path: "/interaction") { request in
                try request.queryParam("item", value: "value")
            }
            .willRespond(with: 200)

        try await builder.verify { ctx in

            let url = try ctx.buildRequestURL(path: "/interaction", queryItems: ["item": "value"])
            let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)

            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertTrue(data.isEmpty)
        }
    }

    func testQueryParamWithMissingValue() async throws {
        try builder
            .uponReceiving("an interaction with item value")
            .withRequest(path: "/interaction") { request in
                try request.queryParam("item", value: "value")
            }
            .willRespond(with: 200)

        try await suppressingPactFailure {
            try await builder.verify { ctx in
                let url = try ctx.buildRequestURL(path: "/interaction")
                let (_, response) = try await URLSession(configuration: .ephemeral).data(from: url)

                let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
                XCTAssertEqual(httpResponse.statusCode, 500)
            }
        }
    }

    func testQueryParamWithWrongValue() async throws {
        try builder
            .uponReceiving("an interaction with item value")
            .withRequest(path: "/interaction") { request in
                try request.queryParam("item", value: "value")
            }
            .willRespond(with: 200)

        try await suppressingPactFailure {
            try await builder.verify { ctx in
                let url = try ctx.buildRequestURL(path: "/interaction", queryItems: ["item": "1"])
                let (_, response) = try await URLSession(configuration: .ephemeral).data(from: url)

                let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
                XCTAssertEqual(httpResponse.statusCode, 500)
            }
        }
    }

    func testQueryParamMatchingBoolean() async throws {
        try await performMatcherTest(named: "bool(true)", matcher: .bool(true), value: "true")
    }

    func testQueryParamMatchingBoolean_Negative() async throws {
        try await performMatcherNegativeTest(named: "bool(true) \(#function)", matcher: .bool(true), value: "not a bool")
    }

    func testQueryParamMatchingNotEmpty() async throws {
        try await performMatcherTest(named: "notEmpty", matcher: .notEmpty(), value: "foo is not empty")
    }

    func testQueryParamMatchingNotEmpty_Negative() async throws {
        try await performMatcherNegativeTest(named: "notEmpty", matcher: .notEmpty(), value: "")
    }

    // v4 only
    func testQueryParamMatchingSemVer() async throws {
        try XCTSkipIf(true, "🐞 'semver' matcher is not supported in query paramaters")
        try await performMatcherTest(named: "semver", matcher: .semver("1.2.3"), value: "1.2.3-beta1")
    }

    // v4 only
    func testQueryParamMatchingSemVer_Negative() async throws {
        try XCTSkipIf(true, "🐞 'semver' matcher is not supported in query paramaters")
        try await performMatcherNegativeTest(named: "semver", matcher: .semver("1.2.3"), value: "not semver")
    }

    func testQueryParamMatchingNumber() async throws {
        try await performMatcherTest(named: "number", matcher: .number(1234), value: "1234")
    }

    func testQueryParamMatchingNumber_Negative() async throws {
        try await performMatcherNegativeTest(named: "number", matcher: .number(1234), value: "not a number")
    }

    func testQueryParamMatchingInteger() async throws {
        try await performMatcherTest(named: "integer", matcher: .integer(4567), value: "4567")
    }

    func testQueryParamMatchingInteger_Negative() async throws {
        try await performMatcherNegativeTest(named: "integer", matcher: .integer(4567), value: "not a number")
    }

    func testQueryParamMatchingDecimal() async throws {
        try await performMatcherTest(named: "decimal", matcher: .decimal(4567.78), value: "4567.78")
    }

    func testQueryParamMatchingDecimal_Negative() async throws {
        try await performMatcherNegativeTest(named: "decimal", matcher: .decimal(4567.78), value: "not a decimal")
    }

    func testQueryParamMatchingIncludes() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/485")
        try await performMatcherTest(named: "includes", matcher: .includes("sub"), value: "substring")
    }

    func testQueryParamMatchingIncludes_Negative() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/484")
        try await performMatcherNegativeTest(named: "includes", matcher: .includes("sub"), value: "string")
    }

    func testQueryParamMatchingLikeNumber() async throws {
        try await performMatcherTest(named: "like", matcher: .like(1), value: "2")
    }

    func testQueryParamMatchingLikeNumber_Negative() async throws {
        try await performMatcherNegativeTest(named: "like", matcher: .like(1), value: "not a number")
    }

    func testQueryParamMatchingLikeString() async throws {
        try await performMatcherTest(named: "like", matcher: .like("string"), value: "a string")
    }

    func testQueryParamMatchingRegex() async throws {
        try await performMatcherTest(named: "regex", matcher: .regex(#"\w+"#, example: "wordchars"), value: "stuff_that_is_words")
    }

    func testQueryParamMatchingRegex_Negative() async throws {
        try await performMatcherNegativeTest(named: "regex", matcher: .regex(#"\d+"#, example: "1234"), value: "not numbers")
    }

    func testQueryParamMatchingEquals() async throws {
        try await performMatcherTest(named: "equals", matcher: .equals("a string"), value: "a string")
    }

    func testQueryParamMatchingEquals_Negative() async throws {
        try await performMatcherNegativeTest(named: "equals", matcher: .equals("a string"), value: "not equal")
    }

    // MARK: - Matching date values in URL query parameters

    func testQueryParamMatchingDate() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/483")
        try await performMatcherTest(named: "date", matcher: .date("1999-12-01", format: "yyyy-MM-dd"), value: "2000-01-12")
    }

    func testQueryParamMatchingDate_Negative() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/483")
        try await performMatcherNegativeTest(named: "date", matcher: .date("1999-12-01", format: "yyyy-MM-dd"), value: "not a date")
    }

    func testQueryParamMatchingTime() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/483")
        try await performMatcherTest(named: "time", matcher: .time("12:13:00", format: "HH:mm:ss"), value: "12:13:00")
    }

    func testQueryParamMatchingTime_Negative() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/483")
        try await performMatcherNegativeTest(named: "time", matcher: .time("12:02", format: "HH:mm"), value: "not a time")
    }

    func testQueryParamMatchingDateTime() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/483")
        try await performMatcherTest(named: "datetime", matcher: .datetime("2022-01-09 12:02:12", format: "yyyy-MM-dd HH:mm:ss"), value: "2034-02-01 10:12:33")
    }

    func testQueryParamMatchingDateTime_Negative() async throws {
        try XCTSkipIf(true, "🐞 https://github.com/pact-foundation/pact-reference/issues/483")
        try await performMatcherNegativeTest(named: "datetime", matcher: .datetime("2022-01-09 12:02:12", format: "yyyy-MM-dd HH:mm:ss"), value: "not timestamp")
    }
}

// MARK: - Private

private extension InteractionQueryTests {

    func performMatcherTest(named: String, matcher: AnyMatcher, value: String) async throws {
        try builder
            .uponReceiving("an interaction with item matching \(named)")
            .withRequest(path: "/interaction") { request in
                try request.queryParam("item", matching: matcher)
            }
            .willRespond(with: 200)

        try await builder.verify { ctx in
            let url = try ctx.buildRequestURL(path: "/interaction", queryItems: ["item": value])
            let (data, response) = try await URLSession(configuration: .ephemeral).data(from: url)

            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            Logger.log(message: #function, data: data)
            XCTAssertEqual(httpResponse.statusCode, 200)
        }
    }

    func performMatcherNegativeTest(named: String, matcher: AnyMatcher, value: String) async throws {
        try builder
            .uponReceiving("an interaction with item matching \(named)")
            .withRequest(path: "/interaction") { request in
                try request.queryParam("item", matching: matcher)
            }
            .willRespond(with: 200)

        try await suppressingPactFailure {
            try await builder.verify { ctx in
                let url = try ctx.buildRequestURL(path: "/interaction", queryItems: ["item": value])
                let (_, response) = try await URLSession(configuration: .ephemeral).data(from: url)

                let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
                XCTAssertEqual(httpResponse.statusCode, 500)
            }
        }
    }
}

private extension PactBuilder.ConsumerContext {

    func buildRequestURL(path: String, queryItems: [String: String] = [:]) throws -> URL {
        var components = try XCTUnwrap(URLComponents(url: mockServerURL, resolvingAgainstBaseURL: false))
        components.path = path
        components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        return try XCTUnwrap(components.url)
    }
}
