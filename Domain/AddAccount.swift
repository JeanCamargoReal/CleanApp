//
//  AddAccount.swift
//  Domain
//
//  Created by Jean Camargo on 07/06/22.
//

import Foundation

public protocol AddAccount {
	func add(addAccountModel: AddAccountModel, completion: @escaping (Result<AccountModel, Error>) -> Void)
}

public struct AddAccountModel {
	public var name: String
	public var email: String
	public var password: String
	public var passwordConfirmation: String
}


