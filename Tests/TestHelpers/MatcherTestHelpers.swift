//
//  Created by Marko Justinek on 25/10/21.
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
@testable import PactSwift

enum MatcherTestHelpers {

	/// Encodes a model containing `AnyEncodable` type and decodes the value into String type
	static func encodeDecode(_ model: [[String: AnyEncodable]]) throws -> [DecodableModel] {
		let data = try JSONEncoder().encode(EncodableModel(params: model).params)
		return try JSONDecoder().decode([DecodableModel].self, from: data)
	}

	struct EncodableModel: Encodable {
		let params: [[String: AnyEncodable]]
	}

	struct DecodableModel: Decodable {
		let match: String
		let min: Int?
		let max: Int?
		let regex: String?
		let value: String?
	}

}
