//
//  HttpPostClient.swift
//  Data
//
//  Created by Jean Camargo on 09/06/22.
//

import Foundation

public protocol HttpPostClient {
	func post(to url: URL, with data: Data?, completion: @escaping (Result <Data?, HttpError>) -> Void)
}
