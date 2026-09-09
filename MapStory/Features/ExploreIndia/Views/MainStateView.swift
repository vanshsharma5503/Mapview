//
//  MainStateView.swift
//  MapStory
//
//  Created by Vansh Sharma on 10/07/26.
//
import SwiftUI

struct MainStateView: View {

    @State private var viewModel = ExploreIndiaViewModel()

    @State private var appeared = false

    var body: some View {

        ZStack {

            // IMPORTANT:
            // Keep the application's existing yellow.
            Color("Bg")
                .ignoresSafeArea()

            ScrollView(
                showsIndicators: false
            ) {

                VStack(
                    alignment: .leading,
                    spacing: 0
                ) {

                    header

                    content
                }
                .padding(.bottom, 35)
            }
        }
        .task {

            viewModel.loadStates()

            withAnimation(
                .spring(
                    response: 0.7,
                    dampingFraction: 0.82
                )
            ) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {

        HStack(
            alignment: .center
        ) {

            VStack(
                alignment: .leading,
                spacing: 5
            ) {

                Text("EXPLORE")
                    .font(
                        .system(
                            size: 12,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .tracking(2.5)
                    .foregroundStyle(
                        Color.orange.opacity(0.95)
                    )

                Text("Explore India")
                    .font(
                        .system(
                            size: 36,
                            weight: .black,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.black.opacity(0.88)
                    )

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
                    Color.black.opacity(0.50)
                )
            }

            Spacer()

            // Small decorative element.
            ZStack {

                Circle()
                    .fill(
                        Color.orange.opacity(0.12)
                    )
                    .frame(
                        width: 54,
                        height: 54
                    )

                Image(
                    systemName: "sun.max.fill"
                )
                .font(
                    .system(
                        size: 24,
                        weight: .bold
                    )
                )
                .foregroundStyle(.orange)
                .rotationEffect(
                    .degrees(
                        appeared ? 8 : -8
                    )
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 24)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {

        if viewModel.isLoading {

            loadingView

        } else if let error = viewModel.error {

            errorView(error)

        } else {

            stateList
        }
    }

    // MARK: - Loading

    private var loadingView: some View {

        VStack(spacing: 12) {

            ProgressView()
                .tint(.orange)

            Text("Exploring India...")
                .font(
                    .system(
                        size: 14,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.black.opacity(0.55)
                )
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 250
        )
    }

    // MARK: - Error

    private func errorView(
        _ error: StateRepositoryError
    ) -> some View {

        VStack(spacing: 12) {

            Image(
                systemName:
                    "exclamationmark.triangle.fill"
            )
            .font(.system(size: 28))
            .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(
                    .system(
                        size: 20,
                        weight: .bold,
                        design: .rounded
                    )
                )

            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 250
        )
    }

    // MARK: - State List

    private var stateList: some View {

        LazyVStack(
            spacing: 16
        ) {

            ForEach(
                Array(viewModel.states.enumerated()),
                id: \.element.id
            ) { index, state in

                NavigationLink {

                    StateDetailView(
                        state: state
                    )

                } label: {

                    StateCardView(
                        state: state
                    )
                }
                .buttonStyle(.plain)
                .opacity(appeared ? 1 : 0)
                .offset(
                    y: appeared ? 0 : 20
                )
                .animation(
                    .spring(
                        response: 0.65,
                        dampingFraction: 0.82
                    )
                    .delay(
                        Double(index) * 0.06
                    ),
                    value: appeared
                )
            }
        }
        .padding(.horizontal, 18)
    }
}

#Preview {

    NavigationStack {
        MainStateView()
    }
}
