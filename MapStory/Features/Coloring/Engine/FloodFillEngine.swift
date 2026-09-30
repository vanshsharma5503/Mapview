enum FloodFillEngine {
    static func changes(
        regionID: Int,
        regionMap: [Int],
        colorLayer: [UInt32],
        newColor: UInt32
    ) -> [ColoringPixelChange] {
        regionMap.indices.compactMap { index in
            guard regionMap[index] == regionID, colorLayer[index] != newColor else { return nil }
            return ColoringPixelChange(index: index, previousColor: colorLayer[index], newColor: newColor)
        }
    }
}
