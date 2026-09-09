//
//  StateCardView.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//
import SwiftUI

struct StateCardView: View {

    let state: IndianState

    var body: some View {

        HStack(spacing: 14) {

            // MARK: - State Artwork

            ZStack {

                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(Color.white.opacity(0.45))

                Image(state.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .padding(3)
            }
            .frame(
                width: 140,
                height: 170
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )

            // MARK: - State Information

            VStack(
                alignment: .leading,
                spacing: 8
            ) {

                Text(state.name)
                    .font(
                        .system(
                            size: 25,
                            weight: .black,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.black.opacity(0.88)
                    )
                    .lineLimit(1)

                Text(state.tagline)
                    .font(
                        .system(
                            size: 14,
                            weight: .medium,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.black.opacity(0.52)
                    )
                    .lineLimit(2)

                Spacer(minLength: 4)

                // Flower

                HStack(spacing: 8) {

                    Image(systemName: "camera.macro")
                        .font(
                            .system(
                                size: 17,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.pink)

                    Text(state.flora.stateFlower)
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            Color.black.opacity(0.78)
                        )
                        .lineLimit(1)
                }

                // Animal

                HStack(spacing: 8) {

                    Image(systemName: "pawprint.fill")
                        .font(
                            .system(
                                size: 16,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(.orange)

                    Text(state.fauna.stateAnimal)
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold,
                                design: .rounded
                            )
                        )
                        .foregroundStyle(
                            Color.black.opacity(0.78)
                        )
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 2)

            // MARK: - Arrow

            ZStack {

                Circle()
                    .fill(
                        Color.orange
                    )
                    .frame(
                        width: 43,
                        height: 43
                    )

                Image(systemName: "chevron.right")
                    .font(
                        .system(
                            size: 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)
            }
        }
        .padding(10)
        .frame(
            maxWidth: .infinity,
            minHeight: 190,
            maxHeight: 190
        )
        .background(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
            .fill(
                Color(
                    red: 0.965,
                    green: 0.935,
                    blue: 0.855
                )
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
            .stroke(
                Color.white.opacity(0.65),
                lineWidth: 1
            )
        )
        .shadow(
            color: .black.opacity(0.09),
            radius: 9,
            x: 0,
            y: 5
        )
        .accessibilityElement(
            children: .combine
        )
        .accessibilityIdentifier(
            "state_card_\(state.id)"
        )
    }
}

#Preview {

    StateCardView(
        state: IndianState(
            id: "punjab",
            name: "Punjab",
            imageName: "punjab",
            tagline: "The Land of Five Rivers",
            flora: Flora(
                stateFlower: "Sword Lily",
                stateTree: "Shisham",
                majorCrops: [
                    "Wheat",
                    "Rice",
                    "Cotton",
                    "Sugarcane"
                ]
            ),
            fauna: Fauna(
                stateAnimal: "Blackbuck",
                stateBird: "Northern Goshawk"
            )
        )
    )
    .padding(18)
    .background(Color("Bg"))
}
