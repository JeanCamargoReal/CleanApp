//
//  AlamofireAdapterTests.swift
//  AlamofireAdapterTests
//
//  Created by Jean Camargo on 13/06/22.
//

import XCTest
import Alamofire

class AlamofireAdapter {
	private let session: Session
	
	init (session: Session = .default) {
		self.session = session
	}
	
	func post(to url: URL) {
		session.request(url).resume()
	}
}

// MARK: - Tests
class AlamofireAdapterTests: XCTestCase {
	func test_() {
		let url = makeUrl()
		let configuration = URLSessionConfiguration.default
		
		configuration.protocolClasses = [UrlProtocolStub.self]
		
		let session = Session(configuration: configuration)
		let sut = AlamofireAdapter(session: session)
		
		sut.post(to: url)
		
		let exp = expectation(description: "waiting")
		
		UrlProtocolStub.observeRequest { request in
			XCTAssertEqual(url, request.url)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)
	}
}

class UrlProtocolStub: URLProtocol {
	static var emit: ((URLRequest) -> Void)?
	
	static func observeRequest(completion: @escaping (URLRequest) -> Void) {
		UrlProtocolStub.emit = completion
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override func startLoading() {
		UrlProtocolStub.emit?(request)
	}
	
	override func stopLoading() {}
}