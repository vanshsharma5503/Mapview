//
//  ExploreIndiaViewModel.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//

import Foundation
import Observation

@Observable
final class ExploreIndiaViewModel {

    private let repository: StateRepositoryProtocol

    private(set) var states: [IndianState] = []
    private(set) var isLoading = false
    private(set) var error: StateRepositoryError?

    init(repository: StateRepositoryProtocol = StateRepository()) {
        self.repository = repository
    }

    func loadStates() {
        guard states.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            states = try repository.fetchStates()
        } catch let repositoryError as StateRepositoryError {
            self.error = repositoryError
        } catch {
            self.error = .unableToReadData(error)
        }

        isLoading = false
    }
}
