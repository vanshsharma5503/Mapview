import SwiftUI

struct ColorPaletteView: View {
    let selectedColor: ColoringPaletteColor
    let onSelect: (ColoringPaletteColor) -> Void

    var body: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 5),
            spacing: 4
        ) {
            ForEach(ColoringPaletteColor.colors) { paletteColor in
                Button {
                    onSelect(paletteColor)
                } label: {
                    Circle()
                        .fill(paletteColor.color)
                        .frame(width: 30, height: 30)
                        .overlay {
                            Circle()
                                .stroke(Color.white, lineWidth: selectedColor == paletteColor ? 3 : 1)
                        }
                        .overlay {
                            Circle()
                                .stroke(Color.brown.opacity(0.55), lineWidth: selectedColor == paletteColor ? 2 : 0.8)
                                .padding(selectedColor == paletteColor ? -3 : 0)
                        }
                        .scaleEffect(selectedColor == paletteColor ? 1.08 : 1)
                        .shadow(color: paletteColor.color.opacity(0.3), radius: 4, y: 2)
                        .frame(maxWidth: .infinity, minHeight: 38)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(paletteColor.name) color")
                .accessibilityAddTraits(selectedColor == paletteColor ? .isSelected : [])
                .accessibilityIdentifier("color_\(paletteColor.id)")
            }
        }
    }
}
