//
//  Model.swift
//  Domain
//
//  Created by Jean Camargo on 09/06/22.
//

import Foundation

public protocol Model: Encodable {}
	
public extension Model {
	func toData() -> Data? {
		return try? JSONEncoder().encode(self)
	}
}

