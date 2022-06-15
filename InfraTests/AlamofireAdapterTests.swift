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
	
	func post(to url: URL, with data: Data?, completion: @escaping (Result<Data, HttpError>) -> Void) {
		session.request(url, method: .post, parameters: data?.toJson(), encoding: JSONEncoding.default).responseData { dataResponse in
			switch dataResponse.result {
				case .failure: completion(.failure(.noConnectivity))
				case .success: break
			}
		}
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
	
	func test_post_should_complete_with_error_when_request_completes_with_error() {
		let sut = makeSut()
		let exp = expectation(description: "waiting")
		
		UrlProtocolStub.simulate(data: nil, response: nil, error: makeError())
		
		sut.post(to: makeUrl(), with: makeValidData()) { result in
			switch result {
				case .failure(let error): XCTAssertEqual(error, .noConnectivity)
				case .success: XCTFail("Expected error got \(result) instead")
			}
			exp.fulfill()
		}
		wait(for: [exp], timeout: 1)
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
		let exp = expectation(description: "waiting")
		var request: URLRequest?
		
		sut.post(to: url, with: data) { _ in exp.fulfill() }

		UrlProtocolStub.observeRequest { request = $0 }
		
		wait(for: [exp], timeout: 1)
		
		action(request!)
	}
}

// MARK: - Stub

class UrlProtocolStub: URLProtocol {
	static var emit: ((URLRequest) -> Void)?
	static var error: Error?
	static var data: Data?
	static var response: HTTPURLResponse?
	
	static func observeRequest(completion: @escaping (URLRequest) -> Void) {
		UrlProtocolStub.emit = completion
	}
	
	static func simulate(data: Data?, response: HTTPURLResponse?, error: Error?) {
		UrlProtocolStub.data = data
		UrlProtocolStub.response = response
		UrlProtocolStub.error = error
	}
	
	override class func canInit(with request: URLRequest) -> Bool {
		return true
	}
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		return request
	}
	
	override func startLoading() {
		UrlProtocolStub.emit?(request)
		
		if let data = UrlProtocolStub.data {
			client?.urlProtocol(self, didLoad: data)
		}
		if let response = UrlProtocolStub.response {
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		}
		if let error = UrlProtocolStub.error {
			client?.urlProtocol(self, didFailWithError: error)
		}
		
		client?.urlProtocolDidFinishLoading(self)
	}
	
	override func stopLoading() {}
}
