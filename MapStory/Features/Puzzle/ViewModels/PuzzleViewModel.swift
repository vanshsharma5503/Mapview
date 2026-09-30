import CoreGraphics
import Foundation
import Observation

@MainActor
@Observable
final class PuzzleViewModel {
    typealias IndexShuffler = ([Int]) -> [Int]

    private(set) var pieces: [PuzzlePiece] = []
    private(set) var difficulty: PuzzleDifficulty
    private(set) var highlightedIndex: Int?
    private(set) var hintSequence = 0
    let imageName: String

    private let shuffleIndices: IndexShuffler
    private let onPuzzleCompleted: () -> Void
    private var hasReportedCompletion = false

    init(
        imageName: String,
        difficulty: PuzzleDifficulty = .easy,
        shuffleIndices: @escaping IndexShuffler = { $0.shuffled() },
        onPuzzleCompleted: @escaping () -> Void = {}
    ) {
        self.imageName = imageName
        self.difficulty = difficulty
        self.shuffleIndices = shuffleIndices
        self.onPuzzleCompleted = onPuzzleCompleted
        restart()
    }

    var configuration: PuzzleConfiguration { difficulty.configuration }
    var placedCount: Int { pieces.count(where: \.isPlaced) }
    var isComplete: Bool { !pieces.isEmpty && placedCount == pieces.count }
    var unplacedPieces: [PuzzlePiece] { pieces.filter { !$0.isPlaced } }

    func setDifficulty(_ difficulty: PuzzleDifficulty) {
        guard self.difficulty != difficulty else { return }
        self.difficulty = difficulty
        restart()
    }

    func restart() {
        let generated = PuzzlePieceGenerator.pieces(configuration: configuration)
        let solved = Array(generated.indices)
        var order = shuffleIndices(solved)
        if order.count != generated.count || Set(order) != Set(solved) {
            order = Array(solved.reversed())
        } else if order == solved, order.count > 1 {
            order.append(order.removeFirst())
        }
        pieces = order.map { generated[$0] }
        highlightedIndex = nil
        hintSequence = 0
        hasReportedCompletion = false
    }

    @discardableResult
    func place(pieceID: PuzzlePiece.ID, dropPoint: CGPoint, boardFrame: CGRect) -> Bool {
        guard !isComplete,
              let index = pieces.firstIndex(where: { $0.id == pieceID && !$0.isPlaced }) else { return false }
        let target = targetCenter(for: pieces[index], in: boardFrame)
        guard hypot(dropPoint.x - target.x, dropPoint.y - target.y) <= configuration.snapTolerance else {
            return false
        }
        pieces[index].isPlaced = true
        highlightedIndex = nil
        if isComplete, !hasReportedCompletion {
            hasReportedCompletion = true
            onPuzzleCompleted()
        }
        return true
    }

    func showHint() {
        highlightedIndex = unplacedPieces.first?.correctIndex
        hintSequence += 1
    }
    func clearHint() { highlightedIndex = nil }

    func targetCenter(for piece: PuzzlePiece, in boardFrame: CGRect) -> CGPoint {
        let width = boardFrame.width / CGFloat(configuration.columns)
        let height = boardFrame.height / CGFloat(configuration.rows)
        return CGPoint(
            x: boardFrame.minX + (CGFloat(piece.column) + 0.5) * width,
            y: boardFrame.minY + (CGFloat(piece.row) + 0.5) * height
        )
    }
}
