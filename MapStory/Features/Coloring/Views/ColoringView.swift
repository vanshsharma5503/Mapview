import SwiftUI

struct ColoringView: View {
    let state: IndianState
    @State private var model: ColoringViewModel

    init(state: IndianState, onColoringCompleted: @escaping () -> Void = {}) {
        self.state = state
        _model = State(initialValue: ColoringViewModel(
            imageName: state.coloringImageName,
            onColoringCompleted: onColoringCompleted
        ))
    }

    var body: some View {
        ZStack {
            Color("Bg")
                .ignoresSafeArea()
                .accessibilityElement()
                .accessibilityIdentifier("coloring_page")
            ColoringStorybookBackground()

            GeometryReader { geometry in
                VStack(spacing: 9) {
                    ColoringTopBar(stateName: state.name, progress: model.progress)

                    if let image = model.renderedImage {
                        ColoringCanvas(
                            image: image,
                            imagePixelSize: model.imagePixelSize,
                            tool: model.selectedTool,
                            onFill: model.fill,
                            onStrokeBegan: model.beginStroke,
                            onStrokeChanged: model.continueStroke,
                            onStrokeEnded: model.endStroke
                        )
                        .frame(maxHeight: .infinity)
                        .layoutPriority(1)

                        VStack(spacing: 7) {
                            ColorPaletteView(
                                selectedColor: model.selectedColor,
                                onSelect: { model.selectedColor = $0 }
                            )

                            ColoringToolbar(
                                selectedTool: model.selectedTool,
                                brushSize: model.selectedBrushSize,
                                canUndo: model.canUndo,
                                canRedo: model.canRedo,
                                onSelectTool: { model.selectedTool = $0 },
                                onSelectBrushSize: { model.selectedBrushSize = $0 },
                                onUndo: model.undo,
                                onRedo: model.redo,
                                onReset: model.reset
                            )
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.86), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.orange.opacity(0.18), lineWidth: 1.5)
                        }
                        .shadow(color: .brown.opacity(0.1), radius: 8, y: 4)
                    } else if let errorMessage = model.errorMessage {
                        ColoringUnavailableView(message: errorMessage)
                    } else {
                        ProgressView("Preparing your coloring page…")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .padding(40)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Color")
        .navigationBarTitleDisplayMode(.inline)
        .task { model.loadIfNeeded() }
        .overlay {
            if model.progress.isComplete {
                ColoringCompletionView(stateName: state.name, onColorAgain: model.reset)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: model.progress.isComplete)
        .sensoryFeedback(.success, trigger: model.completionSequence)
    }
}

private struct ColoringStorybookBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.08))
                    .frame(width: 170, height: 170)
                    .offset(x: -geometry.size.width * 0.38, y: -geometry.size.height * 0.35)
                Circle()
                    .stroke(Color.brown.opacity(0.08), style: StrokeStyle(lineWidth: 3, dash: [5, 8]))
                    .frame(width: 210, height: 210)
                    .offset(x: geometry.size.width * 0.42, y: geometry.size.height * 0.32)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct ColoringTopBar: View {
    let stateName: String
    let progress: ColoringProgress

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "paintpalette.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(Color(red: 0.78, green: 0.34, blue: 0.16))
            VStack(alignment: .leading, spacing: 2) {
                Text("Color \(stateName)")
                    .font(.system(.headline, design: .rounded, weight: .black))
                HStack(spacing: 7) {
                    Text("\(progress.percentage)% Colored")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                ProgressView(value: progress.fraction)
                    .tint(Color(red: 0.78, green: 0.34, blue: 0.16))
                        .frame(maxWidth: 150)
                }
            }
            Text("\(progress.coloredRegions)/\(progress.totalRegions)")
                .font(.system(.caption, design: .rounded, weight: .bold))
        }
        .foregroundStyle(.brown)
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityIdentifier("coloring_progress")
    }
}

private struct ColoringUnavailableView: View {
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.orange)
            Text("Artwork Coming Soon")
                .font(.system(.title3, design: .rounded, weight: .black))
            Text(message)
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

private struct ColoringCompletionView: View {
    let stateName: String
    let onColorAgain: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 15) {
                HStack(spacing: 18) {
                    Text("✨").rotationEffect(.degrees(-12))
                    Text("🎉").font(.system(size: 48))
                    Text("✨").rotationEffect(.degrees(12))
                }
                Text("Beautiful!")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                Text("You completed \(stateName)!")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                Button("Color Again", action: onColorAgain)
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .controlSize(.large)
            }
            .foregroundStyle(.brown)
            .padding(28)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(radius: 24)
            .padding(24)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview("Punjab Coloring") {
    NavigationStack {
        ColoringView(
            state: IndianState(
                id: "punjab",
                name: "Punjab",
                imageName: "pb",
                puzzleImageName: "pb",
                coloringImageName: "tiger_coloring",
                tagline: "The Land of Five Rivers",
                flora: Flora(stateFlower: "Sword Lily", stateTree: "Shisham", majorCrops: ["Wheat", "Rice"]),
                fauna: Fauna(stateAnimal: "Blackbuck", stateBird: "Northern Goshawk")
            )
        )
    }
}
