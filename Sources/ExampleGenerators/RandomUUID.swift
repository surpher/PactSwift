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
		internal let rules: [String: AnyEncodable]? = nil

		/// Generates a random UUID value
		public init(format: Format = .uppercaseHyphenated) {
			let uuid = UUID()
			self.value = {
				switch format {
				case .simple: return uuid.uuidStringSimple
				case .lowercaseHyphenated: return uuid.rfc4122String
				case .uppercaseHyphenated: return uuid.uuidString
				case .urn: return "urn:uuid:\(uuid.rfc4122String)"
				}
			}()
		}

		/// The format of the UUID value
		public enum Format: String {
			/// Simple UUID format (eg: 936DA01f9abd4d9d80c702af85c822a8)
			case simple

			/// Lowercase hyphenated format (eg: 936da01f-9abd-4d9d-80c7-02af85c822a8)
			case lowercaseHyphenated = "lower-case-hyphenated"

			/// Uppercase hyphenated format (eg: 936DA01F-9ABD-4D9D-80C7-02AF85C822A8)
			case uppercaseHyphenated = "upper-case-hyphenated"

			/// URN format (eg: urn:uuid:936da01f-9abd-4d9d-80c7-02af85c822a8)
			case urn = "URN"
		}
	}

}

// MARK: - Objective-C

#if !os(Linux)
@objc(PFGeneratorRandomUUID)
public class ObjcRandomUUID: NSObject, ObjcGenerator {

	let type: ExampleGeneratorExpressible = ExampleGenerator.RandomUUID()

	/// Generates a random UUID value
	public override init() {
		super.init()
	}

}
#endif
