//
//  Created by Marko Justinek on 17/9/20.
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

extension Date {

	enum ISOFormat {
		case date
		case dateTime
		case time

		var formatOptions: ISO8601DateFormatter.Options {
			switch self {
			case .date:
				return [.withFullDate, .withDashSeparatorInDate]
			case .dateTime:
				return [.withFullDate, .withFullTime]
			case .time:
				return [.withFullTime]
			}
		}
	}

	// MARK: - Instance interface

	func formatted(_ format: String) -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter.string(from: self)
	}

	// MARK: - Static interface

	static func formattedDate(format: String?, isoFormat: ISOFormat) -> String {
		if let format = format {
			return Date().formatted(format)
		}

		let formatter = ISO8601DateFormatter()
		formatter.formatOptions = isoFormat.formatOptions
		return formatter.string(from: Date())
	}

}
