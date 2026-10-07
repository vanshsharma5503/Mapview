import SwiftUI

struct StateDetailView: View {

    let state: IndianState

    @Environment(\.dismiss)
    private var dismiss

    @State private var appeared = false

    // ============================================================
    // MARK: - LAYOUT
    // ============================================================

    // Where the card starts (percentage of screen from top).
    // The image is visible above this point.
    private let cardStartRatio: CGFloat = 0.40

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

    var body: some View {

        GeometryReader { geo in

            let fullHeight = geo.size.height
                + geo.safeAreaInsets.top
                + geo.safeAreaInsets.bottom

            let cardTop = fullHeight * cardStartRatio

            ZStack(alignment: .top) {

                // ================================================
                // 1) HERO IMAGE — FILLS THE UPPER HALF
                // ================================================

                Image(state.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geo.size.width,
                        height: fullHeight * 0.58
                    )
                    .clipped()
                    .offset(y: -60)
                    .overlay(
                        // Gradient for back button readability
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.45),
                                Color.black.opacity(0.0)
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )


                // ================================================
                // 2) INFO CARD — OVERLAPS IMAGE, FILLS TO BOTTOM
                // ================================================

                VStack(spacing: 0) {

                    // Capsule handle
                    HStack {
                        Spacer()
                        Capsule()
                            .fill(
                                darkBrown.opacity(0.18)
                            )
                            .frame(
                                width: 46,
                                height: 5
                            )
                        Spacer()
                    }
                    .padding(.top, 14)
                    .padding(.bottom, 16)


                    // Scrollable content
                    ScrollView(
                        .vertical,
                        showsIndicators: false
                    ) {

                        VStack(
                            alignment: .leading,
                            spacing: 20
                        ) {

                            stateHeader

                            activitiesSection

                            natureSection

                            if !state.flora.majorCrops.isEmpty {
                                cropsSection
                            }

                            Spacer()
                                .frame(height: 40)
                        }
                        .padding(.horizontal, 22)
                    }
                }
                .frame(width: geo.size.width)
                .frame(
                    maxHeight: .infinity,
                    alignment: .top
                )
                .background(Color.white)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 34,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 34
                    )
                )
                .shadow(
                    color: .black.opacity(0.15),
                    radius: 22,
                    x: 0,
                    y: -6
                )
                .padding(.top, cardTop)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)


                // ================================================
                // 3) BACK BUTTON
                // ================================================

                HStack {

                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    Color.white.opacity(0.92)
                                )
                                .frame(
                                    width: 48,
                                    height: 48
                                )
                                .shadow(
                                    color: .black.opacity(0.14),
                                    radius: 8,
                                    y: 3
                                )

                            Image(
                                systemName: "chevron.left"
                            )
                            .font(
                                .system(
                                    size: 18,
                                    weight: .bold
                                )
                            )
                            .foregroundStyle(darkBrown)
                        }
                    }
//                    .accessibilityElement(children: .ignore)
//                    .accessibilityIdentifier("state_detail_back_button")
//                    .accessibilityLabel("Back")
//                    .accessibilityHint("Returns to Explore India")
//                    .accessibilityAddTraits(.isButton)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("Navigate Back")
                    .accessibilityHint("Returns to Explore India")
                    .accessibilityAddTraits(.isButton)

                    Spacer()
                }
                .padding(.leading, 18)
                .padding(
                    .top,
                    geo.safeAreaInsets.top + 8
                )
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(
                .spring(
                    response: 0.6,
                    dampingFraction: 0.82
                )
            ) {
                appeared = true
            }
        }
    }


    // ============================================================
    // MARK: - STATE HEADER
    // ============================================================

    private var stateHeader: some View {

        VStack(
            alignment: .leading,
            spacing: 0
        ) {

            // Explore badge
            HStack(spacing: 7) {

                Image(systemName: "sparkles")
                    .font(
                        .system(
                            size: 13,
                            weight: .bold
                        )
                    )

                Text("EXPLORE")
                    .font(
                        .system(
                            size: 12,
                            weight: .heavy,
                            design: .rounded
                        )
                    )
                    .tracking(2.5)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(olive)
            )


            // State Name + Leaf
            HStack(
                alignment: .center,
                spacing: 9
            ) {

                Text(state.name)
                    .font(
                        .system(
                            size: 38,
                            weight: .black,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(darkBrown)

                Image(systemName: "leaf.fill")
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(olive)
                    .rotationEffect(.degrees(-25))
            }
            .padding(.top, 8)


            // Decorative underline
            HStack(spacing: 5) {

                Capsule()
                    .fill(olive)
                    .frame(width: 46, height: 5)

                Capsule()
                    .fill(warmOrange)
                    .frame(width: 14, height: 5)
            }
            .padding(.top, 4)


            // Tagline
            Text(state.tagline)
                .font(
                    .system(
                        size: 18,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    darkBrown.opacity(0.62)
                )
                .padding(.top, 6)


            // Description
            Text(stateDescription)
                .font(
                    .system(
                        size: 14.5,
                        weight: .regular,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    darkBrown.opacity(0.60)
                )
                .lineSpacing(4)
                .padding(.top, 6)
        }
    }


    // ============================================================
    // MARK: - NATURE
    // ============================================================

    private var natureSection: some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(olive, in: Circle())

                    Text("Nature of \(state.name)")
                        .font(.system(size: 21, weight: .black, design: .rounded))
                        .foregroundStyle(darkBrown)
                }

                Text("Meet the plants and animals that make this state special")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(darkBrown.opacity(0.55))
            }

            VStack(spacing: 0) {
                natureItem(
                    icon: "camera.macro",
                    title: "State flower",
                    value: state.flora.stateFlower,
                    color: Color(red: 0.92, green: 0.35, blue: 0.55)
                )

                Divider().padding(.leading, 52)

                natureItem(
                    icon: "leaf.fill",
                    title: "State tree",
                    value: state.flora.stateTree,
                    color: Color(red: 0.22, green: 0.62, blue: 0.35)
                )

                Divider().padding(.leading, 52)

                natureItem(
                    icon: "pawprint.fill",
                    title: "State animal",
                    value: state.fauna.stateAnimal,
                    color: Color(red: 0.90, green: 0.52, blue: 0.18)
                )

                Divider().padding(.leading, 52)

                natureItem(
                    icon: "bird.fill",
                    title: "State bird",
                    value: state.fauna.stateBird,
                    color: Color(red: 0.25, green: 0.55, blue: 0.85)
                )
            }
            .padding(.horizontal, 14)
            .background(
                Color(red: 0.98, green: 0.97, blue: 0.93),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(olive.opacity(0.14), lineWidth: 1)
            )
        }
    }


    // ============================================================
    // MARK: - NATURE CARD
    // ============================================================

    private func natureItem(
        icon: String,
        title: String,
        value: String,
        color: Color
    ) -> some View {

        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(darkBrown.opacity(0.55))

                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(darkBrown.opacity(0.9))
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }


    // ============================================================
    // MARK: - CROPS
    // ============================================================

    private var cropsSection: some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack(spacing: 6) {

                Image(
                    systemName: "leaf.circle.fill"
                )
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )
                .foregroundStyle(warmOrange)

                Text("MAJOR CROPS")
                    .font(
                        .system(
                            size: 11,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .tracking(1.5)
                    .foregroundStyle(
                        darkBrown.opacity(0.55)
                    )
            }

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {

                HStack(spacing: 10) {

                    ForEach(
                        state.flora.majorCrops,
                        id: \.self
                    ) { crop in

                        cropChip(crop)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private func cropChip(
        _ crop: String
    ) -> some View {

        HStack(spacing: 6) {

            Text(cropEmoji(for: crop))
                .font(.system(size: 15))

            Text(crop)
                .font(
                    .system(
                        size: 14,
                        weight: .semibold,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    darkBrown.opacity(0.85)
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.82))
        )
        .overlay(
            Capsule()
                .stroke(
                    olive.opacity(0.22),
                    lineWidth: 1
                )
        )
        .shadow(
            color: Color.black.opacity(0.04),
            radius: 5,
            y: 2
        )
    }

    private func cropEmoji(
        for crop: String
    ) -> String {

        let lower = crop.lowercased()

        if lower.contains("wheat")
            || lower.contains("rice")
            || lower.contains("paddy")
            || lower.contains("grain") {
            return "🌾"
        }
        if lower.contains("cotton") { return "🧵" }
        if lower.contains("sugar") { return "🍬" }
        if lower.contains("maize")
            || lower.contains("corn") {
            return "🌽"
        }
        if lower.contains("tea") { return "🍃" }
        if lower.contains("fruit")
            || lower.contains("apple")
            || lower.contains("mango") {
            return "🍎"
        }
        return "🌱"
    }


    // ============================================================
    // MARK: - ACTIVITIES
    // ============================================================

    private var activitiesSection: some View {

        VStack(
            alignment: .leading,
            spacing: 10
        ) {

            HStack(spacing: 8) {

                Text("✨")
                    .font(.title3)

                Text("Let's Explore!")
                    .font(
                        .system(
                            size: 24,
                            weight: .black,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(darkBrown)
            }

            Text("Choose something fun to discover")
                .font(
                    .system(
                        size: 14,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .foregroundStyle(
                    darkBrown.opacity(0.48)
                )
                .padding(.bottom, 2)

            // Two immediately available activities
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

                NavigationLink {
                    PuzzleView(state: state)
                } label: {
                    ActivityCard(
                        icon: "puzzlepiece.fill",
                        title: "Puzzle",
                        subtitle: "Put it together",
                        accent: .orange,
                        background: Color(
                            red: 1.0,
                            green: 0.67,
                            blue: 0.25
                        ),
                        minHeight: 125
                    )
                }
                .buttonStyle(ActivityCardButtonStyle())
                .accessibilityIdentifier("puzzle_activity_button")

                NavigationLink {
                    ColoringView(state: state)
                } label: {
                    ActivityCard(
                        icon: "paintpalette.fill",
                        title: "Color",
                        subtitle: "Bring it to life",
                        accent: .pink,
                        background: Color(
                            red: 1.0,
                            green: 0.65,
                            blue: 0.72
                        ),
                        minHeight: 125
                    )
                }
                .buttonStyle(ActivityCardButtonStyle())
                .accessibilityIdentifier("color_activity_button")
            }
        }
    }


    // ============================================================
    // MARK: - DESCRIPTION
    // ============================================================

    private var stateDescription: String {

        switch state.id.lowercased() {

        case "punjab":
            return """
            A land of golden fields, vibrant culture \
            and warm-hearted people. Punjab is known \
            for its rich traditions, lush farmlands \
            and five mighty rivers.
            """

        default:
            return """
            Discover the nature, culture and special \
            treasures that make \(state.name) unique.
            """
        }
    }
}


// ================================================================
// MARK: - PREVIEW
// ================================================================

#Preview {

    NavigationStack {

        StateDetailView(
            state: IndianState(
                id: "punjab",
                name: "Punjab",
                imageName: "pb",
                puzzleImageName: "pb",
                coloringImageName: "tiger_coloring",
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
    }
}
