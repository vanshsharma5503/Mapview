import CoreGraphics
import Testing
@testable import MapStory

@MainActor
struct PuzzleViewModelTests {
    @Test(arguments: [
        (PuzzleDifficulty.easy, 4),
        (.medium, 9),
        (.hard, 16),
        (.expert, 25)
    ])
    func difficultyPieceCounts(difficulty: PuzzleDifficulty, count: Int) {
        let model = makeModel(difficulty)
        #expect(model.pieces.count == count)
        #expect(Set(model.pieces.map(\.correctIndex)).count == count)
    }

    @Test func solvedShuffleIsChanged() {
        let model = PuzzleViewModel(imageName: "pb", shuffleIndices: { $0 })
        #expect(model.pieces.map(\.correctIndex) != Array(0..<4))
    }

    @Test func correctPlacementCompletesAndReportsOnce() {
        var completions = 0
        let model = PuzzleViewModel(imageName: "pb", shuffleIndices: { $0.reversed() }, onPuzzleCompleted: { completions += 1 })
        let frame = CGRect(x: 10, y: 20, width: 200, height: 200)
        for piece in model.pieces {
            #expect(model.place(pieceID: piece.id, dropPoint: model.targetCenter(for: piece, in: frame), boardFrame: frame))
        }
        #expect(model.isComplete)
        #expect(completions == 1)
    }

    @Test func incorrectPlacementRemainsUnplaced() {
        let model = makeModel(.medium)
        #expect(!model.place(pieceID: model.pieces[0].id, dropPoint: CGPoint(x: 1_000, y: 1_000), boardFrame: CGRect(x: 0, y: 0, width: 300, height: 300)))
        #expect(model.placedCount == 0)
    }

    @Test func restartClearsProgress() {
        let model = makeModel(.easy)
        let frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        let piece = model.pieces[0]
        _ = model.place(pieceID: piece.id, dropPoint: model.targetCenter(for: piece, in: frame), boardFrame: frame)
        model.restart()
        #expect(model.placedCount == 0)
        #expect(!model.isComplete)
    }

    @Test func hintHighlightsAnUnplacedPieceAndCanReplay() {
        let model = makeModel(.easy)

        model.showHint()
        let firstSequence = model.hintSequence

        #expect(model.highlightedIndex != nil)
        #expect(firstSequence == 1)

        model.showHint()
        #expect(model.hintSequence == firstSequence + 1)

        model.clearHint()
        #expect(model.highlightedIndex == nil)
    }

    private func makeModel(_ difficulty: PuzzleDifficulty) -> PuzzleViewModel {
        PuzzleViewModel(imageName: "pb", difficulty: difficulty, shuffleIndices: { $0.reversed() })
    }
}
