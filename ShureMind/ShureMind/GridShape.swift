import UIKit

// Grid shape types
enum GridShape: String, CaseIterable {
    case diamond = "🔷"
    case spiral = "🌀"
    case circles = "⭕"
    case cross = "➕"
    case triangle = "🔺"
    case star = "⭐"
    case wave = "🌊"
    case hexagon = "🔶"

    var displayName: String {
        return rawValue
    }

    var cellCount: Int {
        switch self {
        case .diamond: return 25
        case .spiral: return 36
        case .circles: return 37
        case .cross: return 29
        case .triangle: return 28
        case .star: return 31
        case .wave: return 30
        case .hexagon: return 37
        }
    }

    // Generate cell positions for each shape
    func generatePositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        switch self {
        case .diamond:
            return generateDiamondPositions(containerSize: containerSize, spacing: spacing)
        case .spiral:
            return generateSpiralPositions(containerSize: containerSize, spacing: spacing)
        case .circles:
            return generateCirclesPositions(containerSize: containerSize, spacing: spacing)
        case .cross:
            return generateCrossPositions(containerSize: containerSize, spacing: spacing)
        case .triangle:
            return generateTrianglePositions(containerSize: containerSize, spacing: spacing)
        case .star:
            return generateStarPositions(containerSize: containerSize, spacing: spacing)
        case .wave:
            return generateWavePositions(containerSize: containerSize, spacing: spacing)
        case .hexagon:
            return generateHexagonPositions(containerSize: containerSize, spacing: spacing)
        }
    }

    // MARK: - Diamond Shape (5x5 diamond)
    private func generateDiamondPositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let rows = [1, 3, 5, 3, 1] // Diamond pattern
        let cellSize = (containerSize.width - spacing * 6) / 5

        for (rowIndex, cellsInRow) in rows.enumerated() {
            let rowY = spacing + CGFloat(rowIndex) * (cellSize + spacing)
            let startX = (containerSize.width - CGFloat(cellsInRow) * cellSize - CGFloat(cellsInRow - 1) * spacing) / 2

            for col in 0..<cellsInRow {
                let x = startX + CGFloat(col) * (cellSize + spacing)
                positions.append((x, rowY))
            }
        }
        return positions
    }

    // MARK: - Spiral Shape (6x6 spiral from center)
    private func generateSpiralPositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let gridSize = 6
        let cellSize = (containerSize.width - spacing * CGFloat(gridSize + 1)) / CGFloat(gridSize)

        // Create spiral pattern
        var visited = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        var row = gridSize / 2, col = gridSize / 2
        let directions = [(0, 1), (1, 0), (0, -1), (-1, 0)] // right, down, left, up
        var dirIndex = 0
        var steps = 1

        positions.append((spacing + CGFloat(col) * (cellSize + spacing), spacing + CGFloat(row) * (cellSize + spacing)))
        visited[row][col] = true

        while positions.count < gridSize * gridSize {
            for _ in 0..<2 {
                for _ in 0..<steps {
                    row += directions[dirIndex].0
                    col += directions[dirIndex].1
                    if row >= 0 && row < gridSize && col >= 0 && col < gridSize && !visited[row][col] {
                        let x = spacing + CGFloat(col) * (cellSize + spacing)
                        let y = spacing + CGFloat(row) * (cellSize + spacing)
                        positions.append((x, y))
                        visited[row][col] = true
                    }
                }
                dirIndex = (dirIndex + 1) % 4
            }
            steps += 1
        }
        return positions
    }

    // MARK: - Concentric Circles (4 circles: 1, 8, 12, 16 cells)
    private func generateCirclesPositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2
        let maxRadius = min(containerSize.width, containerSize.height) / 2 - spacing

        // Center cell
        positions.append((centerX, centerY))

        // Circle 1: 8 cells
        let radius1 = maxRadius * 0.3
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let x = centerX + radius1 * cos(angle)
            let y = centerY + radius1 * sin(angle)
            positions.append((x, y))
        }

        // Circle 2: 12 cells
        let radius2 = maxRadius * 0.6
        for i in 0..<12 {
            let angle = CGFloat(i) * .pi / 6
            let x = centerX + radius2 * cos(angle)
            let y = centerY + radius2 * sin(angle)
            positions.append((x, y))
        }

        // Circle 3: 16 cells
        let radius3 = maxRadius * 0.9
        for i in 0..<16 {
            let angle = CGFloat(i) * .pi / 8
            let x = centerX + radius3 * cos(angle)
            let y = centerY + radius3 * sin(angle)
            positions.append((x, y))
        }

        return positions
    }

    // MARK: - Cross Shape (vertical + horizontal bars)
    private func generateCrossPositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let cellSize = (containerSize.width - spacing * 8) / 7
        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2

        // Vertical bar (7 cells)
        for i in 0..<7 {
            let y = spacing + CGFloat(i) * (cellSize + spacing)
            positions.append((centerX, y))
        }

        // Horizontal bar (6 cells on each side, excluding center)
        for i in 0..<3 {
            let x = spacing + CGFloat(i) * (cellSize + spacing)
            positions.append((x, centerY))
        }
        for i in 4..<7 {
            let x = spacing + CGFloat(i) * (cellSize + spacing)
            positions.append((x, centerY))
        }

        return positions
    }

    // MARK: - Triangle Shape (pyramid: 1+2+3+4+5+6+7 = 28 cells)
    private func generateTrianglePositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let rows = 7
        let cellSize = (containerSize.width - spacing * 8) / 7

        for row in 0..<rows {
            let cellsInRow = row + 1
            let rowY = spacing + CGFloat(row) * (cellSize + spacing)
            let startX = (containerSize.width - CGFloat(cellsInRow) * cellSize - CGFloat(cellsInRow - 1) * spacing) / 2

            for col in 0..<cellsInRow {
                let x = startX + CGFloat(col) * (cellSize + spacing)
                positions.append((x, rowY))
            }
        }

        return positions
    }

    // MARK: - Star Shape (5-pointed star)
    private func generateStarPositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let centerX = containerSize.width / 2
        let centerY = containerSize.height / 2
        let outerRadius = min(containerSize.width, containerSize.height) / 2 - spacing
        let innerRadius = outerRadius * 0.4

        // Center cell
        positions.append((centerX, centerY))

        // 5 outer points (6 cells each)
        for i in 0..<5 {
            let angle = CGFloat(i) * 2 * .pi / 5 - .pi / 2

            // Outer tip
            let tipX = centerX + outerRadius * cos(angle)
            let tipY = centerY + outerRadius * sin(angle)
            positions.append((tipX, tipY))

            // 2 cells along each arm
            for j in 1...2 {
                let ratio = CGFloat(j) / 3.0
                let x = centerX + outerRadius * ratio * cos(angle)
                let y = centerY + outerRadius * ratio * sin(angle)
                positions.append((x, y))
            }

            // Inner valley cells
            let innerAngle = angle + .pi / 5
            let innerX = centerX + innerRadius * cos(innerAngle)
            let innerY = centerY + innerRadius * sin(innerAngle)
            positions.append((innerX, innerY))
        }

        return positions
    }

    // MARK: - Wave Shape (sine wave pattern)
    private func generateWavePositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let cols = 10
        let cellSize = (containerSize.width - spacing * CGFloat(cols + 1)) / CGFloat(cols)
        let amplitude = containerSize.height / 4
        let centerY = containerSize.height / 2

        for col in 0..<cols {
            let x = spacing + CGFloat(col) * (cellSize + spacing)
            let waveOffset = sin(CGFloat(col) * .pi / 3) * amplitude

            // 3 cells per column (top, middle, bottom of wave)
            for row in 0..<3 {
                let y = centerY + waveOffset + CGFloat(row - 1) * (cellSize + spacing)
                positions.append((x, y))
            }
        }

        return positions
    }

    // MARK: - Hexagon Shape (honeycomb pattern)
    private func generateHexagonPositions(containerSize: CGSize, spacing: CGFloat) -> [(x: CGFloat, y: CGFloat)] {
        var positions: [(x: CGFloat, y: CGFloat)] = []
        let cellSize = (containerSize.width - spacing * 8) / 7
        let hexHeight = cellSize * sqrt(3) / 2

        // Hexagon pattern: rows with 4, 5, 6, 7, 6, 5, 4 cells
        let rowCounts = [4, 5, 6, 7, 6, 5, 4]

        for (rowIndex, cellsInRow) in rowCounts.enumerated() {
            let rowY = spacing + CGFloat(rowIndex) * (hexHeight + spacing)
            let offsetX = (rowIndex % 2 == 0) ? cellSize / 2 : 0
            let startX = (containerSize.width - CGFloat(cellsInRow) * cellSize - CGFloat(cellsInRow - 1) * spacing) / 2 + offsetX

            for col in 0..<cellsInRow {
                let x = startX + CGFloat(col) * (cellSize + spacing)
                positions.append((x, rowY))
            }
        }

        return positions
    }
}
