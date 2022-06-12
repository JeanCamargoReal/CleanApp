//
//  RemoteAddAccountTests.swift
//  DataTests
//
//  Created by Jean Camargo on 07/06/22.
//

import XCTest
import Domain
import Data

// MARK: - Tests
class RemoteAddAccountTests: XCTestCase {
	func test_add_should_call_httpClient_with_correct_url() {
		let url = makeUrl()
		let (sut, httpClientSpy) = makeSut(url: url)
		
		sut.add(addAccountModel: makeAddAccountModel()) { _ in }
		
		XCTAssertEqual(httpClientSpy.urls, [url])
	}
	
	func test_add_should_call_httpClient_with_correct_data() {
		let (sut, httpClientSpy) = makeSut()
		let addAccountModel = makeAddAccountModel()
		
		sut.add(addAccountModel: addAccountModel) { _ in }
		
		XCTAssertEqual(httpClientSpy.data, addAccountModel.toData())
	}
	
	func test_add_should_complete_with_error_if_client_completes_with_error() {
		let (sut, httpClientSpy) = makeSut()
		expect(sut, completeWith: .failure(.unexpected)) {
			httpClientSpy.completeWithError(.noConnectivity)
		}
	}
	
	func test_add_should_complete_with_account_if_client_completes_with_valid_data() {
		let (sut, httpClientSpy) = makeSut()
		let account = makeAccountModel()
		
		expect(sut, completeWith: .success(account)) {
			httpClientSpy.completeWithData(account.toData()!)
		}
	}
	
	func test_add_should_complete_with_error_if_client_completes_with_invalid_data() {
		let (sut, httpClientSpy) = makeSut()
		
		expect(sut, completeWith: .failure(.unexpected)) {
			httpClientSpy.completeWithData(makeInvalidData())
		}
	}
}

// MARK: - Extension
extension RemoteAddAccountTests {
	func makeSut(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteAddAccount, httpClientSpy: HttpClientSpy) {
		let httpClientSpy = HttpClientSpy()
		let sut = RemoteAddAccount(url: url, httpClient: httpClientSpy)
		
		checkMemoryLeak(for: sut, file: file, line: line)
		checkMemoryLeak(for: httpClientSpy, file: file, line: line)
		
		return (sut, httpClientSpy)
	}
	
	func checkMemoryLeak(for instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, file: file, line: line)
		}
	}
	
	func expect(_ sut: RemoteAddAccount, completeWith expectedResult: Result<AccountModel, DomainError>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "waiting")
		
		sut.add(addAccountModel: makeAddAccountModel()) { receivedResult in
			switch (expectedResult, receivedResult) {
				case (.failure(let expectedError), .failure(let receivedError)):
					XCTAssertEqual(expectedError, receivedError, file: file, line: line)
				case (.success(let expectedAccount), .success(let receivedAccount)):
					XCTAssertEqual(expectedAccount, receivedAccount, file: file, line: line)
				default:
					XCTFail("Expected \(expectedResult) received \(receivedResult) instead", file: file, line: line)
			}
			exp.fulfill()
		}
		action()
		wait(for: [exp], timeout: 1)
	}
	
	func makeInvalidData() -> Data {
		return Data("invalid_data".utf8)
	}
	
	func makeUrl() -> URL {
		return URL(string: "http://any-url.com")!
	}
	
	func makeAddAccountModel() -> AddAccountModel {
		return AddAccountModel(name: "any_name", email: "any_email@mail.com", password: "any_password", passwordConfirmation: "any_password")
	}
	
	func makeAccountModel() -> AccountModel {
		return AccountModel(id: "any_id", name: "any_name", email: "any_email@mail.com", password: "any_password")
	}
	
	class HttpClientSpy: HttpPostClient {
		var urls = [URL?]()
		var data: Data?
		var completion: ((Result <Data, HttpError>) -> Void)?
		
		func post(to url: URL, with data: Data?, completion: @escaping (Result <Data, HttpError>) -> Void) {
			self.urls.append(url)
			self.data = data
			self.completion = completion
		}
		
		func completeWithError(_ error: HttpError) {
			completion?(.failure(error))
		}
		
		func completeWithData(_ data: Data) {
			completion?(.success(data))
		}
	}
}
