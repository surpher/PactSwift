//
//  MockServer+Extension.swift
//  PactSwiftServices
//
//  Created by Marko Justinek on 14/4/20.
//  Copyright © 2020 Pact Foundation. All rights reserved.
//

import Foundation
import os.log

internal extension MockServer {

	func unusedPort() -> Int32 {
		var port = randomPort
		var (available, description) = tcpPortAvailable(port: port)
		while !available {
			log(description)
			port = randomPort
			(available, description) = tcpPortAvailable(port: port)
		}
		log(description)
		return Int32(port)
	}

}

private extension MockServer {

	var randomPort: in_port_t {
		return in_port_t(arc4random_uniform(2000) + 4000)
	}

	func log(_ message: String, file: String = #file, function: String = #function) {
		os_log("%@ (%@): %@", log: .default, type: .debug, file, function, message)
	}

	// used code from: https://stackoverflow.com/a/49728137
	func tcpPortAvailable(port: in_port_t) -> (Bool, descr: String) {
		let socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
		guard socketFileDescriptor != -1 else {
			return (false, "SocketCreationFailed: \(descriptionOfLastError())")
		}

		var addr = sockaddr_in()
		let sizeOfSockkAddr = MemoryLayout<sockaddr_in>.size
		addr.sin_len = __uint8_t(sizeOfSockkAddr)
		addr.sin_family = sa_family_t(AF_INET)
		addr.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
		addr.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
		addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
		var bindAddress = sockaddr()
		memcpy(&bindAddress, &addr, Int(sizeOfSockkAddr))

		if Darwin.bind(socketFileDescriptor, &bindAddress, socklen_t(sizeOfSockkAddr)) == -1 {
			let details = descriptionOfLastError()
			release(socket: socketFileDescriptor)
			return (false, "\(port), BindFailed, \(details)")
		}

		if listen(socketFileDescriptor, SOMAXCONN ) == -1 {
			let details = descriptionOfLastError()
			release(socket: socketFileDescriptor)
			return (false, "\(port), ListenFailed, \(details)")
		}

		release(socket: socketFileDescriptor)
		return (true, "\(port) is free for use")
	}

	func release(socket: Int32) {
		Darwin.shutdown(socket, SHUT_RDWR)
		close(socket)
	}

	func descriptionOfLastError() -> String {
		return String.init(cString: (UnsafePointer(strerror(errno))))
	}

}
