//
//  HttpError.swift
//  Data
//
//  Created by Jean Camargo on 10/06/22.
//

import Foundation

public enum HttpError: Error {
	case noConnectivity
    case badRequest
    case serverError
    case unauthorized
    case forbidden
}
