// Copyright © 2025 Marko Justinek. All rights reserved.

import XCTest

@testable import PactSwift

extension PactBuilder.ConsumerContext {

    enum ContentType: String {
        case json = "application/json"
        case xml = "application/xml"
        case plain = "text/plain"
        case octetStream = "application/octet-stream"
    }

    enum ConsumerContextError<T: Encodable>: Error {
        case encodingFailure(T?)
    }

    func encode<T: Encodable>(_ body: T, as type: ContentType) throws -> Data? {
        switch type {
        case .json:
            return try JSONEncoder().encode(body)
        case .xml, .plain:
            if let body = body as? String {
                return body.data(using: .utf8)
            }
            throw ConsumerContextError.encodingFailure(body)
        case .octetStream:
            if let body = body as? Data {
                return body
            }
            throw ConsumerContextError.encodingFailure(body)
        }
    }

    func buildURLRequest(path: String) throws -> URLRequest {
        var components = try XCTUnwrap(URLComponents(url: mockServerURL, resolvingAgainstBaseURL: false))
        components.path = path

        var request = URLRequest(url: try XCTUnwrap(components.url))
        request.setValue(ContentType.json.rawValue, forHTTPHeaderField: "Content-Type")

        return request
    }

    func buildURLRequest<T: Encodable>(path: String, body: T, contentType: ContentType = .json) throws -> URLRequest {
        var components = try XCTUnwrap(URLComponents(url: mockServerURL, resolvingAgainstBaseURL: false))
        components.path = path

        var request = URLRequest(url: try XCTUnwrap(components.url))
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try encode(body, as: contentType)

        return request
    }

    func buildURLRequest(path: String, data: Data, contentType: ContentType = .octetStream) throws -> URLRequest {
        var components = try XCTUnwrap(URLComponents(url: mockServerURL, resolvingAgainstBaseURL: false))
        components.path = path

        var request = URLRequest(url: try XCTUnwrap(components.url))
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data

        return request
    }
}
