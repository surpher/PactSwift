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
		public init(_ format: Format = .uppercaseDashed) {
			let uuid = UUID()
			self.value = {
				switch format {
				case .uppercaseDashed: return uuid.uuidString
				case .dashed: return uuid.rfc4122String
				case .simple: return uuid.uuidStringSimple
				}
			}()
		}

		/// The format of the UUID value
		public enum Format {
			case uppercaseDashed
			case dashed
			case simple
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
