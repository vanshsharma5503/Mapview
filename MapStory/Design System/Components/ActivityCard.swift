//
//  ActivityCard.swift
//  MapStory
//
//  Created by Vansh Sharma on 30/08/26.
//

import SwiftUI

struct ActivityCard: View {

    let icon: String
    let title: String
    let subtitle: String
    let accent: Color
    let background: Color
    var minHeight: CGFloat = 155

    @State private var isPressed = false

    // Compact mode when minHeight < 140
    private var isCompact: Bool {
        minHeight < 140
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            // MARK: - Top Row

            HStack {

                // Icon
                Image(systemName: icon)
                    .font(
                        .system(
                            size: isCompact ? 19 : 23,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.white)
                    .frame(
                        width: isCompact ? 44 : 54,
                        height: isCompact ? 44 : 54
                    )
                    .background(
                        Circle()
                            .fill(accent)
                    )
                    .shadow(
                        color: accent.opacity(0.25),
                        radius: 6,
                        y: 3
                    )

                Spacer()

                // Arrow
                Image(systemName: "arrow.up.right")
                    .font(
                        .system(
                            size: isCompact ? 13 : 15,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(
                        Color.black.opacity(0.55)
                    )
                    .frame(
                        width: isCompact ? 32 : 38,
                        height: isCompact ? 32 : 38
                    )
                    .background(
                        Color.white.opacity(0.65)
                    )
                    .clipShape(Circle())
            }

            Spacer(minLength: isCompact ? 6 : 12)

            // MARK: - Title

            Text(title)
                .font(
                    .system(
                        size: isCompact ? 19 : 23,
                        weight: .black,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color(
                        red: 0.20,
                        green: 0.12,
                        blue: 0.07
                    )
                )

            // MARK: - Subtitle

            Text(subtitle)
                .font(
                    .system(
                        size: isCompact ? 12 : 13,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    Color.black.opacity(0.55)
                )
                .padding(.top, isCompact ? 2 : 4)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: isCompact ? 2 : 5)
        }
        .padding(isCompact ? 13 : 16)
        .frame(
            maxWidth: .infinity,
            minHeight: minHeight
        )
        .background(
            background
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: isCompact ? 22 : 26,
                style: .continuous
            )
        )
        .overlay {

            RoundedRectangle(
                cornerRadius: isCompact ? 22 : 26,
                style: .continuous
            )
            .stroke(
                Color.white.opacity(0.55),
                lineWidth: 1.2
            )
        }
        .shadow(
            color: accent.opacity(0.18),
            radius: isCompact ? 8 : 12,
            y: isCompact ? 4 : 7
        )
        .scaleEffect(
            isPressed ? 0.95 : 1
        )
        .animation(
            .spring(
                response: 0.25,
                dampingFraction: 0.7
            ),
            value: isPressed
        )
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: 50,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
        .accessibilityElement(
            children: .combine
        )
        .accessibilityLabel(
            "\(title). \(subtitle)"
        )
    }
}


// MARK: - Preview

#Preview {

    LazyVGrid(
        columns: [
            GridItem(
                .flexible(),
                spacing: 12
            ),
            GridItem(
                .flexible(),
                spacing: 12
            )
        ],
        spacing: 12
    ) {

        ActivityCard(
            icon: "puzzlepiece.fill",
            title: "Puzzle",
            subtitle: "Put it together",
            accent: .orange,
            background: Color(
                red: 1.0,
                green: 0.72,
                blue: 0.32
            ),
            minHeight: 120
        )

        ActivityCard(
            icon: "paintpalette.fill",
            title: "Color",
            subtitle: "Bring it to life",
            accent: .pink,
            background: Color(
                red: 1.0,
                green: 0.68,
                blue: 0.76
            ),
            minHeight: 120
        )

        ActivityCard(
            icon: "leaf.fill",
            title: "Discover",
            subtitle: "Meet nature",
            accent: .green,
            background: Color(
                red: 0.68,
                green: 0.84,
                blue: 0.63
            ),
            minHeight: 120
        )

        ActivityCard(
            icon: "sparkles",
            title: "Quiz",
            subtitle: "Test your knowledge",
            accent: .orange,
            background: Color(
                red: 1.0,
                green: 0.79,
                blue: 0.40
            ),
            minHeight: 120
        )
    }
    .padding(18)
    .background(
        Color("Bg")
    )
}
