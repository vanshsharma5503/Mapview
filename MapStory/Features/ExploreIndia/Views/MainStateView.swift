//
//  MainStateView.swift
//  MapStory
//
//  Created by Vansh Sharma on 10/07/26.
//

import SwiftUI

struct MainStateView: View {

    @State private var viewModel = ExploreIndiaViewModel()

    @FocusState private var isSearchFocused: Bool

    // ============================================================
    // MARK: - COLORS
    // ============================================================

    private let darkBrown = Color(
        red: 0.20,
        green: 0.13,
        blue: 0.08
    )

    private let olive = Color(
        red: 0.43,
        green: 0.46,
        blue: 0.20
    )

    private let warmOrange = Color(
        red: 0.94,
        green: 0.57,
        blue: 0.15
    )

    private let parchment = Color(
        red: 0.965,
        green: 0.935,
        blue: 0.855
    )

    // ============================================================
    // MARK: - BODY
    // ============================================================

    var body: some View {

        ZStack {

            NatureBackground()
                .ignoresSafeArea()

            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                // =================================================
                // HEADER
                // =================================================

                header

                // =================================================
                // SEARCH
                // =================================================

                searchBar

                // =================================================
                // CONTENT
                // =================================================

                content
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                if isSearchFocused {
                                    isSearchFocused = false
                                }
                            }
                    )
            }
        }

        // ========================================================
        // NAVIGATION
        // ========================================================

        .navigationDestination(
            for: String.self
        ) { stateID in

            stateDestination(
                for: stateID
            )
        }

        // ========================================================
        // LOAD DATA
        // ========================================================

        .task {
            viewModel.loadStates()
        }

    }

    // ============================================================
    // MARK: - STATE DESTINATION
    // ============================================================

    @ViewBuilder
    private func stateDestination(
        for stateID: String
    ) -> some View {

        if let state = viewModel.states.first(
            where: {
                $0.id == stateID
            }
        ) {

            StateDetailView(
                state: state
            )
            .accessibilityIdentifier(
                "state_detail_\(state.id)"
            )

        } else {

            ContentUnavailableView(
                "State Not Found",
                systemImage: "map",
                description: Text(
                    "The selected state could not be found."
                )
            )
        }
    }

    // ============================================================
    // MARK: - HEADER
    // ============================================================

    private var header: some View {

        VStack(
            alignment: .leading,
            spacing: 6
        ) {

            Text("Explore India")
                .font(
                    .system(
                        size: 38,
                        weight: .black,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    darkBrown.opacity(0.90)
                )

            HStack(spacing: 5) {

                Capsule()
                    .fill(olive)
                    .frame(
                        width: 40,
                        height: 4
                    )

                Capsule()
                    .fill(warmOrange)
                    .frame(
                        width: 12,
                        height: 4
                    )

                Capsule()
                    .fill(
                        olive.opacity(0.35)
                    )
                    .frame(
                        width: 8,
                        height: 4
                    )
            }

            Text(
                "Discover the nature of every state"
            )
            .font(
                .system(
                    size: 15,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.50)
            )
            .padding(.top, 2)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    // ============================================================
    // MARK: - SEARCH BAR
    // ============================================================

    private var searchBar: some View {

        HStack(
            spacing: 12
        ) {

            // ----------------------------------------------------
            // SEARCH ICON
            // ----------------------------------------------------

            ZStack {

                Circle()
                    .fill(
                        warmOrange.opacity(0.10)
                    )
                    .frame(
                        width: 36,
                        height: 36
                    )

                Image(
                    systemName: "magnifyingglass"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    warmOrange
                )
            }

            // ----------------------------------------------------
            // SEARCH FIELD
            // ----------------------------------------------------

            TextField(
                "Search states…",
                text: $viewModel.searchText
            )
            .font(
                .system(
                    size: 16,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown
            )
            .textFieldStyle(.plain)
            .focused(
                $isSearchFocused
            )
            .submitLabel(.search)

            // ----------------------------------------------------
            // KEYBOARD SUBMIT
            // ----------------------------------------------------

            .onSubmit {
                dismissKeyboard()
            }

            // ====================================================
            // IMPORTANT FOR UI TESTING
            // ====================================================

            .accessibilityIdentifier(
                "state_search_field"
            )

            // ====================================================
            // CLEAR BUTTON
            // ====================================================

            if !viewModel.searchText.isEmpty {

                Button {

                    viewModel.searchText = ""
                    dismissKeyboard()

                } label: {

                    Image(
                        systemName: "xmark.circle.fill"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        darkBrown.opacity(0.32)
                    )
                    .frame(
                        width: 36,
                        height: 36
                    )
                    .contentShape(
                        Circle()
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("clear_search_button")
                .accessibilityLabel("Clear search")
                .accessibilityHint("Clears the current state search")
            }
        }

        // --------------------------------------------------------
        // SEARCH CONTAINER
        // --------------------------------------------------------

        .padding(
            .horizontal,
            12
        )
        .padding(
            .vertical,
            10
        )
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(
                parchment.opacity(0.97)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .stroke(
                isSearchFocused
                    ? warmOrange.opacity(0.60)
                    : Color.white.opacity(0.80),
                lineWidth:
                    isSearchFocused
                    ? 2
                    : 1
            )
        )
        .shadow(
            color:
                Color.black.opacity(
                    isSearchFocused
                    ? 0.10
                    : 0.06
                ),
            radius:
                isSearchFocused
                ? 14
                : 8,
            x: 0,
            y: 5
        )
        .contentShape(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
        )
        .padding(
            .horizontal,
            18
        )
        .padding(
            .bottom,
            14
        )
        .zIndex(100)
    }

    // ============================================================
    // MARK: - KEYBOARD DISMISS
    // ============================================================

    private func dismissKeyboard() {
        isSearchFocused = false
    }

    // ============================================================
    // MARK: - CONTENT
    // ============================================================

    @ViewBuilder
    private var content: some View {

        if viewModel.isLoading {

            loadingView

        } else if let error = viewModel.error {

            ScrollView(
                showsIndicators: false
            ) {

                errorView(error)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
            }

        } else {

            stateList
        }
    }

    // ============================================================
    // MARK: - LOADING
    // ============================================================

    private var loadingView: some View {

        VStack(
            spacing: 16
        ) {

            ZStack {

                Circle()
                    .fill(
                        olive.opacity(0.10)
                    )
                    .frame(
                        width: 72,
                        height: 72
                    )

                Image(
                    systemName: "leaf.fill"
                )
                .font(
                    .system(
                        size: 28,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    olive
                )
            }

            Text(
                "Exploring India…"
            )
            .font(
                .system(
                    size: 15,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.55)
            )

            Text(
                "Finding beautiful stories"
            )
            .font(
                .system(
                    size: 13,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.30)
            )
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
    }

    // ============================================================
    // MARK: - ERROR
    // ============================================================

    private func errorView(
        _ error: StateRepositoryError
    ) -> some View {

        VStack(
            spacing: 16
        ) {

            ZStack {

                Circle()
                    .fill(
                        warmOrange.opacity(0.12)
                    )
                    .frame(
                        width: 68,
                        height: 68
                    )

                Image(
                    systemName:
                        "exclamationmark.triangle.fill"
                )
                .font(
                    .system(
                        size: 30
                    )
                )
                .foregroundStyle(
                    warmOrange
                )
            }

            Text(
                "Something went wrong"
            )
            .font(
                .system(
                    size: 20,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown
            )

            Text(
                error.localizedDescription
            )
            .font(
                .system(
                    size: 14,
                    weight: .regular,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.55)
            )
            .multilineTextAlignment(
                .center
            )
            .padding(
                .horizontal,
                30
            )

            Button {

                viewModel.loadStates()

            } label: {

                HStack(spacing: 7) {

                    Image(
                        systemName:
                            "arrow.clockwise"
                    )

                    Text(
                        "Try Again"
                    )
                }
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    .white
                )
                .padding(
                    .horizontal,
                    26
                )
                .padding(
                    .vertical,
                    12
                )
                .background(
                    Capsule()
                        .fill(
                            warmOrange
                        )
                )
            }
            .buttonStyle(.plain)
        }
        .padding(28)
        .frame(
            maxWidth: .infinity
        )
        .background(
            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
            .fill(
                parchment.opacity(0.80)
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 26,
                style: .continuous
            )
            .stroke(
                Color.white.opacity(0.65),
                lineWidth: 1.2
            )
        )
        .shadow(
            color:
                Color.black.opacity(0.06),
            radius: 14,
            y: 6
        )
        .padding(
            .horizontal,
            20
        )
    }

    // ============================================================
    // MARK: - STATE LIST
    // ============================================================

    private var stateList: some View {

        ScrollView(
            showsIndicators: false
        ) {

            VStack(
                alignment: .leading,
                spacing: 0
            ) {

                // ------------------------------------------------
                // SEARCH RESULT COUNT
                // ------------------------------------------------

                if !viewModel.searchText.isEmpty {

                    HStack {

                        Text(
                            "\(viewModel.filteredStates.count) result\(viewModel.filteredStates.count == 1 ? "" : "s")"
                        )
                        .font(
                            .system(
                                size: 13,
                                weight: .bold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            darkBrown.opacity(0.45)
                        )

                        Spacer()
                    }
                    .padding(
                        .horizontal,
                        4
                    )
                    .padding(
                        .bottom,
                        12
                    )
                }

                // ------------------------------------------------
                // NO RESULTS
                // ------------------------------------------------

                if viewModel.filteredStates.isEmpty
                    && !viewModel.searchText.isEmpty {

                    noResultsView

                } else {

                    LazyVStack(
                        spacing: 16
                    ) {

                        ForEach(
                            viewModel.filteredStates
                        ) { state in

                            NavigationLink(
                                value: state.id
                            ) {

                                StateCardView(
                                    state: state
                                )
                            }

                            .buttonStyle(
                                .plain
                            )

                            // ====================================================
                            // IMPORTANT FOR UI TESTING
                            // ====================================================

                            .accessibilityIdentifier(
                                "state_card_\(state.id)"
                            )

                            .accessibilityLabel(
                                "Open \(state.name)"
                            )

                            .accessibilityHint(
                                "Shows details about \(state.name)"
                            )

                            // ------------------------------------------------
                            // DISMISS KEYBOARD BEFORE NAVIGATION
                            // ------------------------------------------------

                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded {

                                        dismissKeyboard()
                                    }
                            )
                        }
                    }
                }
            }
            .padding(
                .horizontal,
                18
            )
            .padding(
                .bottom,
                40
            )
        }

        // --------------------------------------------------------
        // SCROLL VIEW KEYBOARD DISMISSAL
        // --------------------------------------------------------

        .scrollDismissesKeyboard(
            .interactively
        )
    }

    // ============================================================
    // MARK: - NO RESULTS
    // ============================================================

    private var noResultsView: some View {

        VStack(
            spacing: 14
        ) {

            Image(
                systemName: "magnifyingglass"
            )
            .font(
                .system(
                    size: 32,
                    weight: .light
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.22)
            )

            Text(
                "No states found"
            )
            .font(
                .system(
                    size: 18,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.55)
            )

            Text(
                "Try a different search term"
            )
            .font(
                .system(
                    size: 14,
                    weight: .medium,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.30)
            )
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 220
        )
    }
}

// ================================================================
// MARK: - PREVIEW
// ================================================================

#Preview {

    NavigationStack {

        MainStateView()
    }
}
