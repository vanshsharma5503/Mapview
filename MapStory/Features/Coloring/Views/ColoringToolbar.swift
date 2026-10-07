import SwiftUI

struct ColoringToolbar: View {
    let selectedTool: ColoringTool
    let brushSize: ColoringBrushSize
    let canUndo: Bool
    let canRedo: Bool
    let onSelectTool: (ColoringTool) -> Void
    let onSelectBrushSize: (ColoringBrushSize) -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(ColoringTool.allCases) { tool in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                            onSelectTool(tool)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: tool.symbolName)
                                .font(.system(size: 17, weight: .bold))
                            Text(tool.title)
                                .font(.system(.caption, design: .rounded, weight: .bold))
                        }
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .foregroundStyle(selectedTool == tool ? .white : Color(red: 0.32, green: 0.19, blue: 0.12))
                        .background(
                            selectedTool == tool
                                ? Color(red: 0.78, green: 0.34, blue: 0.16)
                                : Color(red: 1, green: 0.96, blue: 0.86),
                            in: Capsule()
                        )
                        .scaleEffect(selectedTool == tool ? 1.04 : 1)
                        .shadow(
                            color: Color(red: 0.55, green: 0.24, blue: 0.12)
                                .opacity(selectedTool == tool ? 0.24 : 0),
                            radius: 5,
                            y: 3
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(tool.title)
                    .accessibilityAddTraits(selectedTool == tool ? .isSelected : [])
                    .accessibilityIdentifier("coloring_tool_\(tool.rawValue)")
                }
            }

            HStack(spacing: 6) {
                if selectedTool == .brush || selectedTool == .eraser {
                    Picker("Brush size", selection: Binding(get: { brushSize }, set: onSelectBrushSize)) {
                        ForEach(ColoringBrushSize.allCases) { size in
                            Text(size.rawValue.capitalized).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Brush size")
                }
                actionButton("Undo", symbol: "arrow.uturn.backward", enabled: canUndo, action: onUndo)
                actionButton("Redo", symbol: "arrow.uturn.forward", enabled: canRedo, action: onRedo)
                actionButton("Reset", symbol: "arrow.counterclockwise", enabled: true, action: onReset)
            }
        }
    }

    private func actionButton(
        _ title: String,
        symbol: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .frame(width: 38, height: 36)
        }
        .buttonStyle(.bordered)
        .tint(Color(red: 0.48, green: 0.29, blue: 0.18))
        .disabled(!enabled)
        .accessibilityLabel(title)
        .accessibilityIdentifier("coloring_\(title.lowercased())")
    }
}
