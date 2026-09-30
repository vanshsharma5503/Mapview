import CoreGraphics
import Foundation

enum PuzzleDifficulty: String, CaseIterable, Identifiable, Sendable {
    case easy, medium, hard, expert

    var id: Self { self }
    var displayName: String { rawValue.capitalized }

    var configuration: PuzzleConfiguration {
        switch self {
        case .easy: PuzzleConfiguration(rows: 2, columns: 2, snapTolerance: 72)
        case .medium: PuzzleConfiguration(rows: 3, columns: 3, snapTolerance: 54)
        case .hard: PuzzleConfiguration(rows: 4, columns: 4, snapTolerance: 40)
        case .expert: PuzzleConfiguration(rows: 5, columns: 5, snapTolerance: 30)
        }
    }
}

struct PuzzleConfiguration: Equatable, Sendable {
    let rows: Int
    let columns: Int
    let snapTolerance: CGFloat
    var pieceCount: Int { rows * columns }
}

struct PuzzlePiece: Identifiable, Equatable, Sendable {
    let id: Int
    let correctIndex: Int
    let row: Int
    let column: Int
    let normalizedCropRect: CGRect
    var isPlaced = false

    init(correctIndex: Int, row: Int, column: Int, normalizedCropRect: CGRect) {
        id = correctIndex
        self.correctIndex = correctIndex
        self.row = row
        self.column = column
        self.normalizedCropRect = normalizedCropRect
    }
}

enum PuzzlePieceGenerator {
    static func pieces(configuration: PuzzleConfiguration) -> [PuzzlePiece] {
        let cropWidth = 1 / CGFloat(configuration.columns)
        let cropHeight = 1 / CGFloat(configuration.rows)
        return (0..<configuration.pieceCount).map { index in
            let row = index / configuration.columns
            let column = index % configuration.columns
            return PuzzlePiece(
                correctIndex: index,
                row: row,
                column: column,
                normalizedCropRect: CGRect(
                    x: CGFloat(column) * cropWidth,
                    y: CGFloat(row) * cropHeight,
                    width: cropWidth,
                    height: cropHeight
                )
            )
        }
    }
}
