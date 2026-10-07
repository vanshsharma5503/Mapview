
//
//  StateCardView.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//

import SwiftUI

struct StateCardView: View {

    let state: IndianState

    // ============================================================
    // MARK: - COLORS
    // ============================================================

    private let cream = Color(
        red: 0.975,
        green: 0.945,
        blue: 0.870
    )

    private let darkBrown = Color(
        red: 0.20,
        green: 0.14,
        blue: 0.09
    )

    private let mustard = Color(
        red: 0.82,
        green: 0.56,
        blue: 0.16
    )

    private let terracotta = Color(
        red: 0.90,
        green: 0.31,
        blue: 0.12
    )

    // ============================================================
    // MARK: - LAYOUT
    // ============================================================

    private let imageHeight: CGFloat = 150

    // ============================================================
    // MARK: - BODY
    // ============================================================

    var body: some View {

        VStack(
            spacing: 0
        ) {

            // ======================================================
            // IMAGE SECTION
            // ======================================================

            ZStack(
                alignment: .bottomLeading
            ) {

                GeometryReader { geo in

                    Image(
                        state.imageName
                    )
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geo.size.width,
                        height: geo.size.height
                    )
                    .clipped()
                }

                // ==================================================
                // STATE NAME
                // ==================================================

                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {

                    Text(
                        state.name
                    )
                    .font(
                        .system(
                            size: 26,
                            weight: .black,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        .black
                    )

                    Text(
                        state.tagline
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(
                        Color.black.opacity(0.88)
                    )
                    .lineLimit(1)
                }
                .padding(
                    .horizontal,
                    16
                )
                .padding(
                    .vertical,
                    10
                )
                .glassEffect(
                    .regular.tint(
                        Color.white.opacity(0.7)
                    ),
                    in: .rect(
                        cornerRadius: 16
                    )
                )
                .padding(10)
                .offset(
                    x: -15,
                    y: 20
                )
            }
            .frame(
                height: imageHeight
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
            )
            .padding(8)

            // ======================================================
            // INFO SECTION
            // ======================================================

            HStack(
                spacing: 0
            ) {

                // ==================================================
                // NATURE TAGS
                // ==================================================

                HStack(
                    spacing: 8
                ) {

                    natureChip(
                        icon: "leaf.fill",
                        category: "Flora",
                        label:
                            state.flora.stateFlower,
                        color: Color(
                            red: 0.90,
                            green: 0.22,
                            blue: 0.40
                        )
                    )

                    natureChip(
                        icon: "pawprint.fill",
                        category: "Fauna",
                        label:
                            state.fauna.stateAnimal,
                        color: Color(
                            red: 0.94,
                            green: 0.48,
                            blue: 0.10
                        )
                    )
                }

                Spacer(
                    minLength: 8
                )

                // ==================================================
                // NAVIGATION ARROW
                // ==================================================
                //
                // IMPORTANT:
                //
                // This is ONLY a visual indicator.
                //
                // The NavigationLink is in MainStateView.
                //
                // Therefore this arrow cannot navigate to a
                // hard-coded state.
                //
                // ==================================================

                ZStack {

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    terracotta,
                                    Color(
                                        red: 0.94,
                                        green: 0.38,
                                        blue: 0.12
                                    )
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(
                            width: 38,
                            height: 38
                        )
                        .shadow(
                            color:
                                terracotta.opacity(
                                    0.28
                                ),
                            radius: 6,
                            y: 3
                        )

                    Image(
                        systemName:
                            "arrow.right"
                    )
                    .font(
                        .system(
                            size: 14,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        .white
                    )
                }
                .accessibilityHidden(
                    true
                )
            }
            .padding(
                .horizontal,
                16
            )
            .padding(
                .top,
                4
            )
            .padding(
                .bottom,
                14
            )
        }

        // ==========================================================
        // CARD BACKGROUND
        // ==========================================================

        .background(
            cream
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
            .stroke(
                Color.white.opacity(0.60),
                lineWidth: 1.2
            )
        )
        .shadow(
            color:
                Color.black.opacity(0.08),
            radius: 16,
            x: 0,
            y: 8
        )
        .shadow(
            color:
                mustard.opacity(0.10),
            radius: 8,
            x: 0,
            y: 4
        )

        // ==========================================================
        // ACCESSIBILITY
        // ==========================================================

//        .accessibilityElement(
//            children: .combine
//        )
//        .accessibilityIdentifier(
//            "state_card_\(state.id)"
//        )
//        .accessibilityLabel(
//            "Open \(state.name)"
//        )
//        .accessibilityHint(
//            "Shows details about \(state.name)"
//        )
    }

    // ============================================================
    // MARK: - NATURE CHIP
    // ============================================================

    private func natureChip(
        icon: String,
        category: String,
        label: String,
        color: Color
    ) -> some View {

        HStack(
            spacing: 4
        ) {

            Image(
                systemName: icon
            )
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .foregroundStyle(
                color
            )

            Text(
                "\(category):"
            )
            .font(
                .system(
                    size: 11,
                    weight: .bold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.55)
            )

            Text(
                label
            )
            .font(
                .system(
                    size: 12,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundStyle(
                darkBrown.opacity(0.78)
            )
            .lineLimit(1)
            .minimumScaleFactor(
                0.70
            )
        }
        .padding(
            .horizontal,
            10
        )
        .padding(
            .vertical,
            6
        )
        .background(
            Capsule()
                .fill(
                    Color.white.opacity(0.80)
                )
        )
        .overlay(
            Capsule()
                .stroke(
                    color.opacity(0.15),
                    lineWidth: 1
                )
        )
    }
}

// ================================================================
// MARK: - PREVIEW
// ================================================================

#Preview {

    VStack(
        spacing: 16
    ) {

        StateCardView(
            state: IndianState(
                id: "punjab",
                name: "Punjab",
                imageName: "pb",
                puzzleImageName: "pb",
                coloringImageName: "tiger_coloring",
                tagline:
                    "The Land of Five Rivers",
                flora: Flora(
                    stateFlower:
                        "Sword Lily",
                    stateTree:
                        "Shisham",
                    majorCrops: [
                        "Wheat",
                        "Rice",
                        "Cotton",
                        "Sugarcane"
                    ]
                ),
                fauna: Fauna(
                    stateAnimal:
                        "Blackbuck",
                    stateBird:
                        "Northern Goshawk"
                )
            )
        )
    }
    .padding(18)
    .background(
        Color("Bg")
    )
}
