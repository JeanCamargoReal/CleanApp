//
//  AlamofireAdapterTests.swift
//  AlamofireAdapterTests
//
//  Created by Jean Camargo on 13/06/22.
//

import XCTest
import Alamofire
import Data

// MARK: - PROD

class AlamofireAdapter {
	private let session: Session
	
	init (session: Session = .default) {
		self.session = session
	}
	
	func post(to url: URL, with data: Data?) {
		session.request(url, method: .post, parameters: data?.toJson(), encoding: JSONEncoding.default).resume()
	}
}

// MARK: - Tests
class AlamofireAdapterTests: XCTestCase {
	func test_post_should_make_request_with_valid_url_and_method() {
		let url = makeUrl()
		testRequestFor(url: url, data: makeValidData()) { request in
			XCTAssertEqual(url, request.url)
			XCTAssertEqual("POST", request.httpMethod)
			XCTAssertNotNil(request.httpBodyStream)
		}
	}
	
	func test_post_should_make_request_with_not_data() {
		testRequestFor(data: nil) { request in
			XCTAssertNil(request.httpBodyStream)
		}
	}
}

// MARK: - Extensions

extension AlamofireAdapterTests {
	func makeSut(file: StaticString = #filePath, line: UInt = #line) -> AlamofireAdapter {
		let configuration = URLSessionConfiguration.default
		configuration.protocolClasses = [UrlProtocolStub.self]
		let session = Session(configuration: configuration)
		let sut = AlamofireAdapter(session: session)
		
		checkMemoryLeak(for: sut, file: file, line: line)
		
		return sut
	}
	
	func testRequestFor(url: URL = makeUrl(), data: Data?, action: @escaping (URLRequest) -> Void) {
		let sut = makeSut()
		sut.post(to: url, with: data)
		let exp = expectation(description: "waiting")
		
		UrlProtocolStub.observeRequest { request in
			action(request)
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)
	}
}

// MARK: - Stub

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
