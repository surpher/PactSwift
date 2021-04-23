//
//  Created by Marko Justinek on 2/4/20.
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

/// Object describing expected provider state for an interaction
public struct ProviderState: Encodable {

	let name: String
	let params: [String: String]

	/// Object describing expected provider state for an interaction
	///
	/// - parameter description: The description of the state
	/// - parameter params: The `Key` `Value` pair of the expected state (eg: `"user_id": "1"`)
	///
	public init(description: String, params: [String: String]) {
		self.name = description
		self.params = params
	}

}

extension ProviderState: Equatable {

	static public func ==(lhs: ProviderState, rhs: ProviderState) -> Bool {
		lhs.name == rhs.name && lhs.params == rhs.params
	}

}

// MARK: - Objective-C

/*!
		@brief Object describing expected provider state for an interaction

		@discussion This object holds information about the provider state and specific parameters that are required for the specific provider state.

			To use it, simply call @c[[ProviderState alloc] description:@"user exists" params:@{@"id": @"abc123"}];

		@param  description Description of the provider state

		@param  params A dictionary of parameters describing data for the given state
 */
@objc(ProviderState)
public final class ObjCProviderState: NSObject {

	let state: ProviderState

	@objc(initWithDescription:params:)
	public init(description: String, params: [String: String]) {
		state = ProviderState(description: description, params: params)
	}

}
