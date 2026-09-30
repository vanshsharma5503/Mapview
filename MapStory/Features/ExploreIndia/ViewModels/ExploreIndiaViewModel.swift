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

    /// The current search query typed by the user.
    var searchText: String = "" {
        didSet { filterStates() }
    }

    /// States filtered by the current search query.
    private(set) var filteredStates: [IndianState] = []

    init(repository: StateRepositoryProtocol = StateRepository()) {
        self.repository = repository
    }

    func loadStates() {
        guard states.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            states = try repository.fetchStates()
            filterStates()
        } catch let repositoryError as StateRepositoryError {
            self.error = repositoryError
        } catch {
            self.error = .unableToReadData(error)
        }

        isLoading = false
    }

    private func filterStates() {
        guard !searchText.isEmpty else {
            filteredStates = states
            return
        }
        
        let query = searchText.lowercased()
        filteredStates = states.filter { state in
            state.name.lowercased().contains(query)
            || state.tagline.lowercased().contains(query)
        }
    }
}
