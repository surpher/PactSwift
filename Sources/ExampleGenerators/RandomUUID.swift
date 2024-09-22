//
//  Created by Marko Justinek on 16/9/20.
//  Copyright © 2020 Marko Justinek. All rights reserved.
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

public extension ExampleGenerator {

	/// Generates a random UUID value
	struct RandomUUID: ExampleGeneratorExpressible {
		internal let value: Any
		internal let generator: ExampleGenerator.Generator = .uuid
		internal let rules: [String: AnyEncodable]?

		/// Generates a random UUID value
		///
		/// - Parameters:
		///   - format: The format of UUID to generate
		///
		public init(format: Format = .uppercaseHyphenated) {
			self.value = format.value
			self.rules = ["format": AnyEncodable(format.rawValue)]
		}

		/// The format of the UUID value
		public enum Format: String {
			/// Simple UUID format (eg: 936da01f9abd4d9d80c702af85c822a8)
			case simple

			/// Lowercase hyphenated format (eg: 936da01f-9abd-4d9d-80c7-02af85c822a8)
			case lowercaseHyphenated = "lower-case-hyphenated"

			/// Uppercase hyphenated format (eg: 936DA01F-9ABD-4D9D-80C7-02AF85C822A8)
			case uppercaseHyphenated = "upper-case-hyphenated"

			/// URN format (eg: urn:uuid:936da01f-9abd-4d9d-80c7-02af85c822a8)
			case urn = "URN"

			/// Random UUID value in current format
			internal var value: String {
				switch self {
				case .simple:
					return UUID().uuidStringSimple
				case .lowercaseHyphenated:
					return UUID().rfc4122String
				case .uppercaseHyphenated:
					return UUID().uuidString
				case .urn:
					return "urn:uuid:\(UUID().rfc4122String)"
				}
			}
		}
	}

}

// MARK: - Objective-C

@objc(PFGeneratorRandomUUID)
public class ObjcRandomUUID: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible

	/// Generates a random UUID value
	///
	/// Uses default lower-case-hyphenated format
	public override init() {
		type = ExampleGenerator.RandomUUID()

		super.init()
	}

	/// Generates a random UUID value in desired format
	///
	///     // 0 - Simple UUID format (eg: 936DA01f9abd4d9d80c702af85c822a8)
	///     // 1 - Lowercase hyphenated format (eg: 936da01f-9abd-4d9d-80c7-02af85c822a8)
	///     // 2 - Uppercase hyphenated format (eg: 936DA01F-9ABD-4D9D-80C7-02AF85C822A8)
	///     // 3 - URN format (eg: urn:uuid:936da01f-9abd-4d9d-80c7-02af85c822a8)
	///
	///     // Using with enum Int id:
	///     PFGeneratorRandomUUID *randomUUID = [[PFGeneratorRandomUUID alloc] initWithFormat: 2];
	///     // or using enum case:
	///     PFGeneratorRandomUUID *randomUUID = [[PFGeneratorRandomUUID alloc] initWithFormat: ObjcUUIDFormatUppercaseHyphenated];
	///
	@objc(initWithFormat:)
	public init(format: ObjcUUIDFormat) {
		type = ExampleGenerator.RandomUUID(format: format.bridged)

		super.init()
	}

	/// The format of the UUID value
	@objc public enum ObjcUUIDFormat: Int {
		case simple = 0
		case lowercaseHyphenated = 1
		case uppercaseHyphenated = 2
		case urn = 3

		// Bridges the ObjC.RandomUUID.Format to Swift.RandomUUID.Format
		fileprivate var bridged: ExampleGenerator.RandomUUID.Format {
			switch self {
			case .simple: return .simple
			case .lowercaseHyphenated: return .lowercaseHyphenated
			case .uppercaseHyphenated: return .uppercaseHyphenated
			case .urn: return .urn
			}
		}
	}

}
