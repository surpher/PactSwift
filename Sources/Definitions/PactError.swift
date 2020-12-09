//
//  Created by Marko Justinek on 27/4/20.
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

struct PactError {

	let type: String
	let method: String
	let path: String
	let request: RequestError?
	let mismatches: [MismatchError]?

}

extension PactError: Decodable {

	enum CodingKeys: String, CodingKey {
		case type
		case method
		case path
		case request
		case mismatches
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		type = try container.decode(String.self, forKey: .type)
		method = try container.decode(String.self, forKey: .method)
		path = try container.decode(String.self, forKey: .path)
		request = try? container.decode(RequestError.self, forKey: .request)
		mismatches = try? container.decodeIfPresent([MismatchError].self, forKey: .mismatches)
	}

}
