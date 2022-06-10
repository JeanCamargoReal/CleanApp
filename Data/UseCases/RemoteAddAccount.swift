//
//  RemoteAddAccount.swift
//  Data
//
//  Created by Jean Camargo on 09/06/22.
//

import Foundation
import Domain

public final class RemoteAddAccount {
	private let url: URL
	private let httpClient: HttpPostClient
	
	public init(url: URL, httpClient: HttpPostClient) {
		self.url = url
		self.httpClient = httpClient
	}
	
	public func add(addAccountModel: AddAccountModel, completion: @escaping (DomainError) -> Void) {
		httpClient.post(to: url, with: addAccountModel.toData()) { error in
			completion(.unexpected)
		}
	}
}
