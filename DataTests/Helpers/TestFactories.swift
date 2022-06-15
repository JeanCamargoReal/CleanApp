//
//  TestFactories.swift
//  DataTests
//
//  Created by Jean Camargo on 12/06/22.
//

import Foundation

func makeInvalidData() -> Data {
	return Data("invalid_data".utf8)
}

func makeValidData() -> Data {
	return Data("{\"name\":\"Jean\"}".utf8)
}

func makeUrl() -> URL {
	return URL(string: "http://any-url.com")!
}

func makeError() -> Error {
	return NSError(domain: "any_error", code: 0)
}
