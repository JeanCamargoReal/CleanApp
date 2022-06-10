//
//  ExtensionHelpers.swift
//  Data
//
//  Created by Jean Camargo on 10/06/22.
//

import Foundation

public extension Data {
	func toModel<T: Decodable>() -> T? {
		return try? JSONDecoder().decode(T.self, from: self)
	}
}
