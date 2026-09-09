//
//  StateRepositoryProtocol.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//


import Foundation

protocol StateRepositoryProtocol {
    func fetchStates() throws -> [IndianState]
}

final class StateRepository: StateRepositoryProtocol {

    func fetchStates() throws -> [IndianState] {

        guard let url = Bundle.main.url(
            forResource: "StateData",
            withExtension: "json"
        ) else {
            throw StateRepositoryError.dataFileNotFound
        }

        let data: Data

        do {
            data = try Data(contentsOf: url)
        } catch {
            throw StateRepositoryError.unableToReadData(error)
        }

        do {
            return try JSONDecoder().decode(
                [IndianState].self,
                from: data
            )
        } catch {
            throw StateRepositoryError.invalidData(error)
        }
    }
}