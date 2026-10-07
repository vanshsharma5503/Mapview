import SwiftUI

struct ColoringCanvas: View {
    let image: UIImage
    let imagePixelSize: CGSize
    let tool: ColoringTool
    let onFill: (CGPoint) -> Void
    let onStrokeBegan: (CGPoint) -> Void
    let onStrokeChanged: (CGPoint) -> Void
    let onStrokeEnded: () -> Void

    @State private var isStroking = false
    @State private var zoomScale: CGFloat = 1
    @State private var gestureScale: CGFloat = 1
    @State private var zoomAnchor: UnitPoint = .center
    @State private var panOffset: CGSize = .zero
    @State private var panGestureOffset: CGSize = .zero

    private let minimumZoom: CGFloat = 1
    private let maximumZoom: CGFloat = 4

    var body: some View {
        GeometryReader { geometry in
            let imageFrame = aspectFitFrame(imageSize: imagePixelSize, in: geometry.size)
            let effectiveScale = clampedZoom(zoomScale * gestureScale)
            let scaledImageFrame = scaledFrame(imageFrame, scale: effectiveScale, anchor: zoomAnchor)
            let zoomedFrame = scaledImageFrame.offsetBy(
                dx: panOffset.width + panGestureOffset.width,
                dy: panOffset.height + panGestureOffset.height
            )

            Image(uiImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: zoomedFrame.width, height: zoomedFrame.height)
                .position(x: zoomedFrame.midX, y: zoomedFrame.midY)
                .contentShape(Rectangle())
                .modifier(
                    ColoringCanvasInteraction(
                        tool: tool,
                        imageFrame: zoomedFrame,
                        imagePixelSize: imagePixelSize,
                        isStroking: $isStroking,
                        isZoomed: effectiveScale > minimumZoom,
                        onPanChanged: { panGestureOffset = $0 },
                        onPanEnded: {
                            commitPan(
                                translation: $0,
                                scaledFrame: scaledImageFrame,
                                containerSize: geometry.size
                            )
                        },
                        onFill: onFill,
                        onStrokeBegan: onStrokeBegan,
                        onStrokeChanged: onStrokeChanged,
                        onStrokeEnded: onStrokeEnded
                    )
                )

            ColoringZoomControls(
                scale: effectiveScale,
                canZoomOut: effectiveScale > minimumZoom,
                canZoomIn: effectiveScale < maximumZoom,
                onZoomOut: { setZoom(effectiveScale - 0.5) },
                onReset: { setZoom(1) },
                onZoomIn: { setZoom(effectiveScale + 0.5) }
            )
            .padding(10)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color.brown.opacity(0.3), lineWidth: 2))
        .shadow(color: .brown.opacity(0.18), radius: 14, y: 7)
        .simultaneousGesture(
            MagnifyGesture(minimumScaleDelta: 0.02)
                .onChanged { value in
                    zoomAnchor = value.startAnchor
                    gestureScale = value.magnification
                }
                .onEnded { value in
                    zoomScale = clampedZoom(zoomScale * value.magnification)
                    gestureScale = 1
                }
        )
        .accessibilityLabel("Coloring canvas")
        .accessibilityHint("Pinch or use the zoom buttons to enlarge small areas, then drag to move around the picture")
    }

    private func aspectFitFrame(imageSize: CGSize, in container: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }
        let scale = min(container.width / imageSize.width, container.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(x: (container.width - size.width) / 2, y: (container.height - size.height) / 2, width: size.width, height: size.height)
    }

    private func scaledFrame(_ frame: CGRect, scale: CGFloat, anchor: UnitPoint) -> CGRect {
        let anchorPoint = CGPoint(
            x: frame.minX + frame.width * anchor.x,
            y: frame.minY + frame.height * anchor.y
        )
        return CGRect(
            x: anchorPoint.x - (anchorPoint.x - frame.minX) * scale,
            y: anchorPoint.y - (anchorPoint.y - frame.minY) * scale,
            width: frame.width * scale,
            height: frame.height * scale
        )
    }

    private func clampedZoom(_ scale: CGFloat) -> CGFloat {
        min(max(scale, minimumZoom), maximumZoom)
    }

    private func setZoom(_ scale: CGFloat) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.82)) {
            if scale <= minimumZoom {
                zoomAnchor = .center
                panOffset = .zero
                panGestureOffset = .zero
            }
            zoomScale = clampedZoom(scale)
            gestureScale = 1
        }
    }

    private func commitPan(
        translation: CGSize,
        scaledFrame: CGRect,
        containerSize: CGSize
    ) {
        let proposed = CGSize(
            width: panOffset.width + translation.width,
            height: panOffset.height + translation.height
        )
        let minimumVisibleLength: CGFloat = 64
        let horizontalRange = (
            lower: minimumVisibleLength - scaledFrame.maxX,
            upper: containerSize.width - minimumVisibleLength - scaledFrame.minX
        )
        let verticalRange = (
            lower: minimumVisibleLength - scaledFrame.maxY,
            upper: containerSize.height - minimumVisibleLength - scaledFrame.minY
        )

        withAnimation(.spring(response: 0.3, dampingFraction: 0.84)) {
            panOffset = CGSize(
                width: min(max(proposed.width, horizontalRange.lower), horizontalRange.upper),
                height: min(max(proposed.height, verticalRange.lower), verticalRange.upper)
            )
            panGestureOffset = .zero
        }
    }
}

private struct ColoringZoomControls: View {
    let scale: CGFloat
    let canZoomOut: Bool
    let canZoomIn: Bool
    let onZoomOut: () -> Void
    let onReset: () -> Void
    let onZoomIn: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            zoomButton("Zoom out", symbol: "minus.magnifyingglass", enabled: canZoomOut, action: onZoomOut)
                .accessibilityIdentifier("coloring_zoom_out")
            Button(action: onReset) {
                Text("\(Int((scale * 100).rounded()))%")
                    .font(.system(.caption2, design: .rounded, weight: .black))
                    .foregroundStyle(Color(red: 0.31, green: 0.18, blue: 0.11))
                    .frame(minWidth: 44, minHeight: 34)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset zoom")
            .accessibilityIdentifier("coloring_zoom_reset")
            zoomButton("Zoom in", symbol: "plus.magnifyingglass", enabled: canZoomIn, action: onZoomIn)
                .accessibilityIdentifier("coloring_zoom_in")
        }
        .padding(5)
        .background(Color(red: 1, green: 0.95, blue: 0.82).opacity(0.94), in: Capsule())
        .overlay(Capsule().stroke(Color.brown.opacity(0.25), lineWidth: 1))
        .shadow(color: .brown.opacity(0.14), radius: 6, y: 3)
    }

    private func zoomButton(
        _ label: String,
        symbol: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.72, green: 0.29, blue: 0.14))
                .frame(width: 36, height: 34)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
        .accessibilityLabel(label)
    }
}

private struct ColoringCanvasInteraction: ViewModifier {
    let tool: ColoringTool
    let imageFrame: CGRect
    let imagePixelSize: CGSize
    @Binding var isStroking: Bool
    let isZoomed: Bool
    let onPanChanged: (CGSize) -> Void
    let onPanEnded: (CGSize) -> Void
    let onFill: (CGPoint) -> Void
    let onStrokeBegan: (CGPoint) -> Void
    let onStrokeChanged: (CGPoint) -> Void
    let onStrokeEnded: () -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if isZoomed && tool == .fill {
            content
                .gesture(
                    DragGesture(minimumDistance: 5, coordinateSpace: .local)
                        .onChanged { value in onPanChanged(value.translation) }
                        .onEnded { value in onPanEnded(value.translation) }
                )
                .simultaneousGesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            guard let point = imagePoint(from: value.location) else { return }
                            onFill(point)
                        }
                )
        } else if tool == .fill {
            content.gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        guard let point = imagePoint(from: value.location) else { return }
                        onFill(point)
                    }
            )
        } else {
            content.gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        guard let point = imagePoint(from: value.location) else { return }
                        if isStroking {
                            onStrokeChanged(point)
                        } else {
                            isStroking = true
                            onStrokeBegan(point)
                        }
                    }
                    .onEnded { _ in
                        guard isStroking else { return }
                        isStroking = false
                        onStrokeEnded()
                    }
            )
        }
    }

    private func imagePoint(from point: CGPoint) -> CGPoint? {
        guard imageFrame.contains(point), imageFrame.width > 0, imageFrame.height > 0 else { return nil }
        return CGPoint(
            x: (point.x - imageFrame.minX) / imageFrame.width * imagePixelSize.width,
            y: (point.y - imageFrame.minY) / imageFrame.height * imagePixelSize.height
        )
    }
}
