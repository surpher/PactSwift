//  Created by Marko Justinek on 20/10/20.
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

import Foundation

enum Toolbox {

	/// Merges the Pact top level elements into one dictionary thac can be Encoded
	/// - Parameters:
	///   - body: The PactBuilder processed object representing interaction's body
	///   - query: The PactBuilder processed object representing interaction's query
	///   - header The PactBuilder processed object representing interaction's header
	static func merge(body: AnyEncodable?, query: AnyEncodable? = nil, header: AnyEncodable? = nil) -> AnyEncodable? {
		var merged: [String: AnyEncodable] = [:]

		if let header = header {
			merged["header"] = header
		}

		if let body = body {
			merged["body"] = body
		}

		if let query = query {
			merged["query"] = query
		}

		return merged.isEmpty ? nil : AnyEncodable(merged)
	}

	/// Runs the `Any` type through PactBuilder and returns a Pact tuple
	/// - Parameters:
	///   - element: The object to process through PactBuilder
	///   - interactionElement: The network interaction element the object relates to
	static func process(element: Any?, for interactionElement: PactInteractionNode) -> (node: AnyEncodable?, rules: AnyEncodable?, generators: AnyEncodable?)? {
		if let element = element {
			do {
				let encodedElement = try PactBuilder(with: element, for: interactionElement).encoded()
				return (node: encodedElement.node, rules: encodedElement.rules, generators: encodedElement.generators)
			} catch {
				fatalError("Can not process \(interactionElement.rawValue) with non-encodable (non-JSON safe) values")
			}
		}

		return nil
	}

}
