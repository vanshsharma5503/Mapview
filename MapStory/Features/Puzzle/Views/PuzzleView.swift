import SwiftUI

struct PuzzleView: View {
    let state: IndianState
    @State private var model: PuzzleViewModel

    init(state: IndianState, onPuzzleCompleted: @escaping () -> Void = {}) {
        self.state = state
        _model = State(initialValue: PuzzleViewModel(
            imageName: state.puzzleImageName,
            onPuzzleCompleted: onPuzzleCompleted
        ))
    }

    var body: some View {
        ZStack {
            PuzzleBackground()
            GeometryReader { geometry in
                VStack(spacing: 10) {
                    PuzzleHeader(stateName: state.name)
                    DifficultyPicker(selection: model.difficulty, onSelect: model.setDifficulty)
                    PuzzleProgress(placed: model.placedCount, total: model.pieces.count)
                    PuzzlePlayArea(model: model)
                        .frame(maxHeight: .infinity)
                        .layoutPriority(1)
                    PuzzleControls(canHint: !model.isComplete, onHint: showHint, onRestart: model.restart)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Puzzle")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if model.isComplete {
                PuzzleCompletionOverlay(
                    imageName: model.imageName,
                    stateName: state.name,
                    onPlayAgain: model.restart
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: model.isComplete)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.8), trigger: model.hintSequence)
    }

    private func showHint() {
        model.showHint()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.2))
            model.clearHint()
        }
    }
}

private struct PuzzleBackground: View {
    var body: some View {
        ZStack {
            Color("Bg")
            Circle()
                .fill(Color.white.opacity(0.22))
                .frame(width: 330, height: 330)
                .blur(radius: 35)
                .offset(x: -170, y: -310)
            Circle()
                .fill(Color.orange.opacity(0.16))
                .frame(width: 300, height: 300)
                .blur(radius: 42)
                .offset(x: 180, y: 360)
        }
        .ignoresSafeArea()
    }
}

private struct PuzzleHeader: View {
    let stateName: String

    var body: some View {
        VStack(spacing: 2) {
            Text("Piece Together \(stateName)")
                .font(.system(.headline, design: .rounded, weight: .black))
                .foregroundStyle(Color(red: 0.24, green: 0.14, blue: 0.08))
            Text("Drag each picture piece to its matching place.")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(Color.brown.opacity(0.72))
        }
        .multilineTextAlignment(.center)
    }
}

private struct DifficultyPicker: View {
    let selection: PuzzleDifficulty
    let onSelect: (PuzzleDifficulty) -> Void

    var body: some View {
        HStack(spacing: 6) {
            ForEach(PuzzleDifficulty.allCases) { difficulty in
                Button(difficulty.displayName) { onSelect(difficulty) }
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(selection == difficulty ? .white : Color(red: 0.32, green: 0.19, blue: 0.12))
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(selection == difficulty ? Color(red: 0.78, green: 0.34, blue: 0.16) : Color.white.opacity(0.82), in: Capsule())
                    .accessibilityHint("Uses \(difficulty.configuration.pieceCount) pieces")
            }
        }
        .accessibilityLabel("Puzzle difficulty")
    }
}

private struct PuzzleProgress: View {
    let placed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: "star.fill").foregroundStyle(.orange)
            Text("\(placed) of \(total) pieces")
                .font(.system(.headline, design: .rounded, weight: .bold))
            Spacer()
            HStack(spacing: 3) {
                ForEach(0..<min(total, 9), id: \.self) { index in
                    Circle()
                        .fill(index < placed ? Color.orange : Color.brown.opacity(0.16))
                        .frame(width: 7, height: 7)
                }
            }
            .accessibilityHidden(true)
        }
        .foregroundStyle(.brown)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(placed) of \(total) puzzle pieces placed")
    }
}

private struct PuzzleDragState {
    let piece: PuzzlePiece
    let displaySize: CGSize
    let globalLocation: CGPoint
}

private struct PuzzlePlayArea: View {
    let model: PuzzleViewModel
    @State private var boardFrame: CGRect = .zero
    @State private var draggedPiece: PuzzleDragState?

    var body: some View {
        GeometryReader { geometry in
            let playAreaFrame = geometry.frame(in: .global)
            let maximumBoardHeight = max(150, geometry.size.height * 0.58)
            let boardWidth = min(geometry.size.width, 440, maximumBoardHeight / 0.75)
            let boardSize = CGSize(width: boardWidth, height: boardWidth * 0.75)

            ZStack {
                VStack(spacing: 10) {
                    PuzzleBoard(model: model, size: boardSize)
                        .background {
                            GeometryReader { boardGeometry in
                                Color.clear
                                    .onAppear { boardFrame = boardGeometry.frame(in: .global) }
                                    .onChange(of: boardGeometry.frame(in: .global)) { _, frame in boardFrame = frame }
                            }
                        }

                    PuzzleTray(
                        model: model,
                        boardSize: boardSize,
                        boardFrame: boardFrame,
                        onDragChanged: { piece, displaySize, location in
                            draggedPiece = PuzzleDragState(
                                piece: piece,
                                displaySize: displaySize,
                                globalLocation: location
                            )
                        },
                        onDragEnded: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.76)) {
                                draggedPiece = nil
                            }
                        }
                    )
                    .frame(maxHeight: .infinity)
                }

                if let draggedPiece {
                    PuzzlePieceArtwork(
                        imageName: model.imageName,
                        piece: draggedPiece.piece,
                        configuration: model.configuration,
                        boardSize: boardSize,
                        pieceSize: draggedPiece.displaySize
                    )
                    .frame(width: draggedPiece.displaySize.width, height: draggedPiece.displaySize.height)
                    .scaleEffect(1.13)
                    .rotationEffect(.degrees(-2))
                    .shadow(color: .black.opacity(0.3), radius: 14, y: 9)
                    .position(
                        x: draggedPiece.globalLocation.x - playAreaFrame.minX,
                        y: draggedPiece.globalLocation.y - playAreaFrame.minY
                    )
                    .allowsHitTesting(false)
                    .transition(.scale(scale: 0.88).combined(with: .opacity))
                    .zIndex(100)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

private struct PuzzleBoard: View {
    let model: PuzzleViewModel
    let size: CGSize

    var body: some View {
        GeometryReader { proxy in
            let pieceSize = CGSize(
                width: proxy.size.width / CGFloat(model.configuration.columns),
                height: proxy.size.height / CGFloat(model.configuration.rows)
            )
            ZStack(alignment: .topLeading) {
                Image(model.imageName)
                    .resizable().scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height).clipped().opacity(0.12)
                ForEach(model.pieces) { piece in
                    PuzzleDestination(
                        piece: piece,
                        configuration: model.configuration,
                        isHighlighted: model.highlightedIndex == piece.correctIndex,
                        size: pieceSize
                    )
                        .offset(x: CGFloat(piece.column) * pieceSize.width, y: CGFloat(piece.row) * pieceSize.height)
                    if piece.isPlaced {
                        PuzzlePieceArtwork(
                            imageName: model.imageName,
                            piece: piece,
                            configuration: model.configuration,
                            boardSize: proxy.size,
                            pieceSize: pieceSize
                        )
                        .offset(x: CGFloat(piece.column) * pieceSize.width, y: CGFloat(piece.row) * pieceSize.height)
                        .transition(.scale(scale: 1.12).combined(with: .opacity))
                        .accessibilityLabel("Puzzle piece \(piece.correctIndex + 1) placed")
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .background(Color(red: 0.94, green: 0.87, blue: 0.69))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.brown.opacity(0.35), lineWidth: 3))
        .shadow(color: .brown.opacity(0.18), radius: 12, y: 7)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Puzzle board")
    }
}

private struct PuzzleDestination: View {
    let piece: PuzzlePiece
    let configuration: PuzzleConfiguration
    let isHighlighted: Bool
    let size: CGSize

    var body: some View {
        PuzzleTileShape(piece: piece, configuration: configuration)
            .fill(isHighlighted ? Color.orange.opacity(0.34) : Color.clear)
            .overlay {
                PuzzleTileShape(piece: piece, configuration: configuration)
                    .stroke(Color.brown.opacity(isHighlighted ? 0.78 : 0.2), lineWidth: isHighlighted ? 3 : 1)
            }
            .frame(width: size.width, height: size.height)
            .scaleEffect(isHighlighted ? 0.92 : 1)
            .shadow(color: Color.orange.opacity(isHighlighted ? 0.75 : 0), radius: 12)
            .animation(.easeInOut(duration: 0.25), value: isHighlighted)
    }
}

private struct PuzzleTray: View {
    let model: PuzzleViewModel
    let boardSize: CGSize
    let boardFrame: CGRect
    let onDragChanged: (PuzzlePiece, CGSize, CGPoint) -> Void
    let onDragEnded: () -> Void

    var body: some View {
        let columnCount = min(model.configuration.columns, 4)
        let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: columnCount)
        let pieceWidth = min((boardSize.width - CGFloat(columnCount - 1) * 10) / CGFloat(columnCount), 110)
        let displaySize = CGSize(width: pieceWidth, height: pieceWidth * 0.75)
        ScrollView(.vertical, showsIndicators: true) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(model.unplacedPieces) { piece in
                    DraggablePuzzlePiece(
                        model: model,
                        piece: piece,
                        boardSize: boardSize,
                        boardFrame: boardFrame,
                        displaySize: displaySize,
                        onDragChanged: onDragChanged,
                        onDragEnded: onDragEnded
                    )
                }
            }
            .padding(12)
        }
        .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.orange.opacity(0.24), lineWidth: 2))
        .accessibilityLabel("Puzzle piece tray")
        .accessibilityIdentifier("puzzle_piece_tray")
    }
}

private struct DraggablePuzzlePiece: View {
    let model: PuzzleViewModel
    let piece: PuzzlePiece
    let boardSize: CGSize
    let boardFrame: CGRect
    let displaySize: CGSize
    let onDragChanged: (PuzzlePiece, CGSize, CGPoint) -> Void
    let onDragEnded: () -> Void
    @State private var isDragging = false

    var body: some View {
        PuzzlePieceArtwork(
            imageName: model.imageName,
            piece: piece,
            configuration: model.configuration,
            boardSize: boardSize,
            pieceSize: displaySize
        )
        .frame(minWidth: 44, minHeight: 44)
        .shadow(color: .black.opacity(0.14), radius: 5, y: 3)
        .scaleEffect(isDragging ? 1.06 : 1)
        .phaseAnimator(
            [CGFloat.zero, -8, 8, -6, 6, 0],
            trigger: model.hintSequence
        ) { content, phase in
            content.offset(x: model.highlightedIndex == piece.correctIndex ? phase : 0)
        } animation: { _ in
            .easeInOut(duration: 0.08)
        }
        .gesture(
            LongPressGesture(minimumDuration: 0.12, maximumDistance: 12)
                .sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: .global))
                .onChanged { value in
                    switch value {
                    case .first(true):
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.72)) {
                            isDragging = true
                        }
                    case .second(true, let drag?):
                        isDragging = true
                        onDragChanged(piece, displaySize, drag.location)
                    default:
                        break
                    }
                }
                .onEnded { value in
                    defer {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.74)) {
                            isDragging = false
                            onDragEnded()
                        }
                    }
                    guard case .second(true, let drag?) = value else { return }
                    _ = model.place(pieceID: piece.id, dropPoint: drag.location, boardFrame: boardFrame)
                }
        )
        .accessibilityLabel("Puzzle piece \(piece.correctIndex + 1) of \(model.pieces.count)")
        .accessibilityHint("Drag this piece onto its matching place on the puzzle board")
    }
}

private struct PuzzlePieceArtwork: View {
    let imageName: String
    let piece: PuzzlePiece
    let configuration: PuzzleConfiguration
    let boardSize: CGSize
    let pieceSize: CGSize

    var body: some View {
        Image(imageName)
            .resizable().scaledToFill()
            .frame(width: boardSize.width, height: boardSize.height)
            .offset(
                x: boardSize.width / 2 - (CGFloat(piece.column) + 0.5) * boardSize.width / CGFloat(configuration.columns),
                y: boardSize.height / 2 - (CGFloat(piece.row) + 0.5) * boardSize.height / CGFloat(configuration.rows)
            )
            .frame(width: pieceSize.width, height: pieceSize.height)
            .clipShape(PuzzleTileShape(piece: piece, configuration: configuration))
            .overlay {
                PuzzleTileShape(piece: piece, configuration: configuration)
                    .stroke(Color.white.opacity(0.88), lineWidth: 2)
            }
            .contentShape(PuzzleTileShape(piece: piece, configuration: configuration))
    }
}

private struct PuzzleTileShape: Shape {
    let piece: PuzzlePiece
    let configuration: PuzzleConfiguration

    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) * 0.13
        let depth = radius * 1.45
        let middleX = rect.midX
        let middleY = rect.midY
        let hasOutwardTabs = (piece.row + piece.column).isMultiple(of: 2)
        var path = Path()

        path.move(to: rect.origin)
        if piece.row == 0 {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        } else {
            path.addLine(to: CGPoint(x: middleX - radius, y: rect.minY))
            path.addCurve(
                to: CGPoint(x: middleX + radius, y: rect.minY),
                control1: CGPoint(x: middleX - radius, y: rect.minY + (hasOutwardTabs ? -depth : depth)),
                control2: CGPoint(x: middleX + radius, y: rect.minY + (hasOutwardTabs ? -depth : depth))
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        }

        if piece.column == configuration.columns - 1 {
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        } else {
            path.addLine(to: CGPoint(x: rect.maxX, y: middleY - radius))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: middleY + radius),
                control1: CGPoint(x: rect.maxX + (hasOutwardTabs ? depth : -depth), y: middleY - radius),
                control2: CGPoint(x: rect.maxX + (hasOutwardTabs ? depth : -depth), y: middleY + radius)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        }

        if piece.row == configuration.rows - 1 {
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        } else {
            path.addLine(to: CGPoint(x: middleX + radius, y: rect.maxY))
            path.addCurve(
                to: CGPoint(x: middleX - radius, y: rect.maxY),
                control1: CGPoint(x: middleX + radius, y: rect.maxY + (hasOutwardTabs ? depth : -depth)),
                control2: CGPoint(x: middleX - radius, y: rect.maxY + (hasOutwardTabs ? depth : -depth))
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }

        if piece.column == 0 {
            path.addLine(to: rect.origin)
        } else {
            path.addLine(to: CGPoint(x: rect.minX, y: middleY + radius))
            path.addCurve(
                to: CGPoint(x: rect.minX, y: middleY - radius),
                control1: CGPoint(x: rect.minX + (hasOutwardTabs ? -depth : depth), y: middleY + radius),
                control2: CGPoint(x: rect.minX + (hasOutwardTabs ? -depth : depth), y: middleY - radius)
            )
            path.closeSubpath()
        }

        return path
    }
}

private struct PuzzleControls: View {
    let canHint: Bool
    let onHint: () -> Void
    let onRestart: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onHint) {
                Label("Hint", systemImage: "lightbulb.fill")
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
            .disabled(!canHint)
            .accessibilityIdentifier("puzzle_hint_button")
            Button(action: onRestart) {
                Label("Restart", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
            .accessibilityIdentifier("puzzle_restart_button")
        }
        .font(.system(.subheadline, design: .rounded, weight: .bold))
        .foregroundStyle(Color(red: 0.34, green: 0.20, blue: 0.12))
        .buttonStyle(.borderedProminent)
        .tint(Color(red: 0.94, green: 0.76, blue: 0.42))
    }
}

private struct PuzzleCompletionOverlay: View {
    let imageName: String
    let stateName: String
    let onPlayAgain: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.28).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "sparkles").font(.system(size: 36, weight: .bold)).foregroundStyle(.orange)
                Text("Puzzle Complete!").font(.system(.title, design: .rounded, weight: .black))
                Text("Beautiful work—you put together \(stateName).")
                    .font(.system(.body, design: .rounded, weight: .medium)).multilineTextAlignment(.center)
                Image(imageName).resizable().scaledToFit().frame(maxHeight: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                Button("Play Again", action: onPlayAgain)
                    .buttonStyle(.borderedProminent).tint(.orange).controlSize(.large)
            }
            .foregroundStyle(.brown)
            .padding(24).frame(maxWidth: 420)
            .background(Color(red: 1, green: 0.96, blue: 0.84), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.orange.opacity(0.5), lineWidth: 3))
            .shadow(radius: 24).padding(24)
        }
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}

#Preview("Punjab Puzzle") {
    NavigationStack {
        PuzzleView(
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
                    majorCrops: ["Wheat", "Rice", "Cotton", "Sugarcane"]
                ),
                fauna: Fauna(
                    stateAnimal: "Blackbuck",
                    stateBird: "Northern Goshawk"
                )
            )
        )
    }
}
