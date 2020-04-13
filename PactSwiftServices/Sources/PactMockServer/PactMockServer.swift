//
//  PactMockServer.swift
//  PactServices
//
//  Created by Marko Justinek on 12/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import Foundation

#if SWIFT_PACKAGE
import PactMockServer
#endif


class MockServer {

	init() {
		let mockServer = create_mock_server(nil, nil)
		print("#warning: mockServer returned Int32: \(mockServer)")
	}

}
