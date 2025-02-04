//
//  Created by Oliver Jones on 9/1/2023.
//  Copyright © 2023 Oliver Jones. All rights reserved.
//
//  See LICENSE file for licensing information.
//

@testable import PactSwift

import XCTest

final class InteractionTests: InteractionTestCase {

    func testGetEvents() async throws {
        try builder
            .uponReceiving("a request to retrieve all events with no authorization")
            .given("There are events")
            .withRequest(path: "/events") { request in
                try request
                    .queryParam("something", value: "orOther")
                    .queryParam("limit", matching: .decimal(100))
                    .queryParam("includeOthers", value: "false")
            }
            .willRespond(with: 200) { response in
                try response.htmlBody()
                try response.header("Content-Type", value: "text/html")
            }

        try await builder.verify { ctx in
            var components = try XCTUnwrap(URLComponents(url: ctx.mockServerURL, resolvingAgainstBaseURL: false))
            components.path = "/events"
            components.queryItems = [
                URLQueryItem(name: "something", value: "orOther"),
                URLQueryItem(name: "limit", value: "100.0"),
                URLQueryItem(name: "includeOthers", value: "false"),
            ]

            let (data, response) = try await URLSession(configuration: .ephemeral).data(from: try XCTUnwrap(components.url))

            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "Content-Type"), "text/html")
            XCTAssertTrue(data.isEmpty)
        }
    }

    func testCreateEvent() async throws {
        try builder
            .uponReceiving("a request to create an event with no authorization")
            .given("There are events")
            .withRequest(method: .POST, path: "/events") { request in
                try request.header("Accept", value: "application/json")
            }
            .willRespond(with: 201) { response in
                try response.htmlBody("OK")
            }

        try await builder.verify { ctx in
            var components = try XCTUnwrap(URLComponents(url: ctx.mockServerURL, resolvingAgainstBaseURL: false))
            components.path = "/events"

            var request = URLRequest(url: try XCTUnwrap(components.url))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)

            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 201)
            XCTAssertEqual(httpResponse.value(forHTTPHeaderField: "Content-Type"), "text/html")
            XCTAssertEqual(data, "OK".data(using: .utf8))
        }
    }

    func testGetEvent() async throws {

        struct Response: Decodable {
            var id: String
            var age: Int
            var name: String
            var postcodes: [Int]
            var something: String
            var hex: String
            var birthday: String
        }

        try builder
            .uponReceiving("a request for an event with no authorization")
            .given("There are events")
            .withRequest(method: .GET, regex: #"/events/\d+"#, example: "/events/100") { request in
                try request
                    .queryParam("sorted", value: "true")
                    .header("Accept", value: "application/json")
            }
            .willRespond(with: 200) { response in
                try response.jsonBody(
                    .like(
                        [
                            "id": .randomUUID(like: "urn:uuid:\(UUID())", format: .urn),
                            "age": .randomInteger(like: 1, range: 1...100),
                            "name": .randomString(like: "An name", size: 50),
                            "postcodes": .eachLike(AnyMatcher.integer(1234), max: 2),
                            "something": .regex(#"\d{4}"#, example: "1234"),
                            "hex": .randomHexadecimal(like: "DEADBEEF", digits: 8),
                            "birthday": .generatedDate("2022-12-11", format: "yyyy-MM-dd", expression: "+ 1 day")
                        ]
                    )
                )
            }

        try await builder.verify { ctx in
            var components = try XCTUnwrap(URLComponents(url: ctx.mockServerURL, resolvingAgainstBaseURL: false))
            components.path = "/events/23"
            components.queryItems = [URLQueryItem(name: "sorted", value: "true")]

            var request = URLRequest(url: try XCTUnwrap(components.url))
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("1", forHTTPHeaderField: "X-Version")

            let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)

            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 200)

            let contentType = try XCTUnwrap(httpResponse.value(forHTTPHeaderField: "Content-Type"))
            XCTAssertTrue(contentType.contains("application/json"))

            let body = try JSONDecoder().decode(Response.self, from: data)

            XCTAssertEqual(body.id.prefix(9), "urn:uuid:")
            XCTAssertGreaterThanOrEqual(body.age, 1)
            XCTAssertLessThanOrEqual(body.age, 100)
            XCTAssertEqual(body.name.count, 50)
            XCTAssertFalse(body.postcodes.isEmpty)
            XCTAssertGreaterThanOrEqual(body.postcodes.count, 1)
            XCTAssertEqual(body.something, "1234")
            XCTAssertEqual(body.hex.count, 8)
        }
    }

    func testSendingABinaryBody() async throws {
        guard let imagePath = Bundle.module.path(forResource: "test_image", ofType: "jpg") else {
            throw TestError.failure("Could not load test image!")
        }

        let fileData = try Data(contentsOf: URL(fileURLWithPath: imagePath))

        try builder
            .uponReceiving("A request to upload a file")
            .given(
                .init(
                    description: "Some state expecting binary body",
                    name: #function,
                    value: String(describing: #line)
                )
            )
            .withRequest(method: .POST, path: "/uploads") { request in
                try request.body(fileData, contentType: "application/octet-stream")
            }
            .willRespond(with: 201)

        try await builder.verify { context in
            let urlRequest = try context.buildURLRequest(path: "/uploads", data: fileData, contentType: .octetStream)

            let (_, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 201)
        }
    }

    func testReceivingABinaryBody() async throws {
        guard let imagePath = Bundle.module.path(forResource: "test_image", ofType: "jpg") else {
            throw TestError.failure("Could not load test image!")
        }

        let fileData = try Data(contentsOf: URL(fileURLWithPath: imagePath))

        try builder
            .uponReceiving("A request to fetch a file")
            .given(
                .init(
                    description: "Some state providing binary body",
                    name: #function,
                    value: String(describing: #line)
                )
            )
            .withRequest(method: .GET, path: "/uploads/1")
            .willRespond(with: 200)  { response in
                try response.body(fileData, contentType: "application/octet-stream")
            }

        try await builder.verify { context in
            let urlRequest = try context.buildURLRequest(path: "/uploads/1")

            let (data, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 200)
            XCTAssertEqual(fileData, data)
        }
    }

    func testSendingMultipartForm() async throws {
        let boundary = "Boundary-\(UUID().uuidString)"
        let multipartData = try multipartData(boundary: boundary)

        try builder
            .uponReceiving("A request to submit form data")
            .given(
                .init(
                    description: "Some state expecting multipart form-data",
                    name: #function,
                    value: String(describing: #line)
                )
            )
            .withRequest(method: .POST, path: "/submissions") { request in
                try request.body(multipartData, contentType: "multipart/form-data; boundary=\(boundary)")
            }
            .willRespond(with: 200)

        try await builder.verify { context in
            let urlRequest = try context.buildURLRequest(
                path: "/submissions",
                data: multipartData,
                contentType: .custom("multipart/form-data; boundary=\(boundary)")
            )

            let (_, response) = try await URLSession(configuration: .ephemeral).data(for: urlRequest)
            let httpResponse = try XCTUnwrap(response as? HTTPURLResponse)
            XCTAssertEqual(httpResponse.statusCode, 200)
        }
    }
}

// MARK: - Private

private extension InteractionTests {

    func multipartData(boundary: String) throws -> Data {
        var body = Data()

        let imageFileName = "test_image"
        let imageFileExt = "jpg"
        guard let imagePath = Bundle.module.path(forResource: imageFileName, ofType: imageFileExt) else {
            throw TestError.failure("Could not load test image!")
        }

        // Add text field
        let textFieldName = "Foo"
        let textFieldValue = "BarBaz"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(textFieldName)\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(textFieldValue)\r\n".data(using: .utf8)!)

        // Add a binary file
        let fileFieldName = "file"
        let fileName = "\(imageFileName).\(imageFileExt)"
        let mimeType = "image/jpeg"
        let fileData = try Data(contentsOf: URL(fileURLWithPath: imagePath))

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // Close the boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}
