//
//  StateRepositoryError.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//


import Foundation

enum StateRepositoryError: LocalizedError {

    case dataFileNotFound
    case unableToReadData(Error)
    case invalidData(Error)

    var errorDescription: String? {

        switch self {

        case .dataFileNotFound:
            return "State data file could not be found."

        case .unableToReadData(let error):
            return "Unable to read state data: \(error.localizedDescription)"

        case .invalidData(let error):
            return "State data is invalid: \(error.localizedDescription)"
        }
    }
}