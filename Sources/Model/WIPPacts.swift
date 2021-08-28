//
//  Created by Marko Justinek on 24/8/21.
//  Copyright © 2021 Marko Justinek. All rights reserved.
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

/// The configuration used when verifying WIP pacts
public struct WIPPacts {

	/// The date from which the changed pacts are to be included
	let sinceDate: Date

	/// The provider
	let providerVersion: String

	/// Configuration for verifying WIP pacts
	///
	/// - Parameters:
	///   - since: The date from which the WIP pacts are to be included in verification
	///   - providerVersion: The provider version being verified
	///
	/// See [Work in Progress pacts](https://docs.pact.io/pact_broker/advanced_topics/wip_pacts/) for more

	/// - Warning: The `providerVersion` value set in the `VerificationResult` object is used if provided
	///
	public init(since date: Date, providerVersion: String) {
		self.sinceDate = date
		self.providerVersion = providerVersion
	}

}
