// The MIT License
//
// Copyright (c) 2018 Dariusz Bukowski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

struct Triangle {
    private static let scaleFactor: CGFloat = 1.1
    let vertices: (CGPoint, CGPoint, CGPoint)

    var scaledVertices: (CGPoint, CGPoint, CGPoint) {
        // The triangles are scaled by Triangle.scaleFactor to avoid empty spaces between the triangles.
        let centerOfGravity = CGPoint(x: (self.vertices.0.x + self.vertices.1.x + self.vertices.2.x) / 3.0,
                                      y: (self.vertices.0.y + self.vertices.1.y + self.vertices.2.y) / 3.0)
        return (CGPoint(x: centerOfGravity.x + Triangle.scaleFactor * (self.vertices.0.x - centerOfGravity.x),
                        y: centerOfGravity.y + Triangle.scaleFactor * (self.vertices.0.y - centerOfGravity.y)),
                CGPoint(x: centerOfGravity.x + Triangle.scaleFactor * (self.vertices.1.x - centerOfGravity.x),
                        y: centerOfGravity.y + Triangle.scaleFactor * (self.vertices.1.y - centerOfGravity.y)),
                CGPoint(x: centerOfGravity.x + Triangle.scaleFactor * (self.vertices.2.x - centerOfGravity.x),
                        y: centerOfGravity.y + Triangle.scaleFactor * (self.vertices.2.y - centerOfGravity.y)))
    }

    var boundingRect: CGRect {
        let scaledVertices = self.scaledVertices
        let minX = min(scaledVertices.0.x, scaledVertices.1.x, scaledVertices.2.x)
        let maxX = max(scaledVertices.0.x, scaledVertices.1.x, scaledVertices.2.x)
        let minY = min(scaledVertices.0.y, scaledVertices.1.y, scaledVertices.2.y)
        let maxY = max(scaledVertices.0.y, scaledVertices.1.y, scaledVertices.2.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    var center: CGPoint {
        let boundingRect = self.boundingRect
        return CGPoint(x: boundingRect.midX, y: boundingRect.midY)
    }

    var path: CGPath {
        let scaledVertices = self.scaledVertices
        let path = UIBezierPath()
        path.move(to: scaledVertices.0)
        path.addLine(to: scaledVertices.1)
        path.addLine(to: scaledVertices.2)
        path.close()
        let boundingRect = self.boundingRect
        path.apply(CGAffineTransform(translationX: -boundingRect.origin.x,
                                     y: -boundingRect.origin.y))
        return path.cgPath
    }
}

extension CALayer {

    /**
     Divides the layer into triangles and animates their movement into a specified direction with fading away.

     - Parameter direction: The direction of the triangles' movement.
     - Parameter estimatedTrianglesCount: Estimated number of triangles after dividing the layer. The final number will also depend on the layer bounds' size.
     - Parameter completion: Block that will be executed when the animation finishes.
     */
    open func disintegrate(direction: DisintegrationDirection = DisintegrationDirection.random(),
                           estimatedTrianglesCount: Int = 66,
                           completion: (() -> ())? = nil) {
        self.getRandomTriangles(direction: direction,
                                estimatedTrianglesCount: estimatedTrianglesCount) { triangles in
            DispatchQueue.main.async {
                self.disintegrate(withTriangles: triangles,
                                  direction: direction,
                                  completion: completion)
            }
        }
    }

    private func disintegrate(withTriangles triangles: [Triangle],
                              direction: DisintegrationDirection,
                              completion: (() -> ())? = nil) {
        guard let snapshot = self.snapshot() else {
            return
        }

        let scale = UIScreen.main.scale
        let initialSublayers = self.sublayers ?? []
        var triangleLayers = [CALayer]()

        let maxAnimationBeginTime: Double = 2.0
        let animationDuration: Double = 3.0
        let animationTimingRandomFactor: CGFloat = 0.1

        for (index, triangle) in triangles.enumerated() {
            let bounds = triangle.boundingRect
            let triangleImage = snapshot.cropping(to: bounds.applying(CGAffineTransform(scaleX: scale, y: scale)))

            let triangleMaskLayer = CAShapeLayer()
            triangleMaskLayer.frame = CGRect(origin: .zero, size: bounds.size)
            triangleMaskLayer.path = triangle.path

            let triangleLayer = CALayer()
            triangleLayer.frame = bounds
            triangleLayer.contents = triangleImage
            triangleLayer.mask = triangleMaskLayer
            triangleLayer.shouldRasterize = true
            triangleLayer.drawsAsynchronously = true
            triangleLayers.append(triangleLayer)
            self.addSublayer(triangleLayer)

            let animationBeginTime = CACurrentMediaTime() + CFTimeInterval(Double(index) / Double(triangles.count) * maxAnimationBeginTime)

            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.fromValue = 1.0
            alphaAnimation.toValue = 0.0
            alphaAnimation.duration = animationDuration + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            alphaAnimation.beginTime = animationBeginTime + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            alphaAnimation.fillMode = CAMediaTimingFillMode.backwards
            alphaAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            triangleLayer.opacity = 0.0
            triangleLayer.add(alphaAnimation, forKey: nil)

            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            let targetScale = CGFloat.random(between: 0.2, and: 0.4)
            scaleAnimation.fromValue = triangleLayer.value(forKeyPath: "transform.scale")
            scaleAnimation.toValue = targetScale
            scaleAnimation.duration = animationDuration + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            scaleAnimation.beginTime = animationBeginTime + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            scaleAnimation.fillMode = CAMediaTimingFillMode.backwards
            triangleLayer.setValue(targetScale, forKeyPath: "transform.scale")
            triangleLayer.add(scaleAnimation, forKey: nil)

            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            let targetRotation = CGFloat.random(between: -0.5, and: 0.5)
            rotateAnimation.fromValue = triangleLayer.value(forKeyPath: "transform.rotation")
            rotateAnimation.toValue = targetRotation
            rotateAnimation.duration = animationDuration + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            rotateAnimation.beginTime = animationBeginTime + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            rotateAnimation.fillMode = CAMediaTimingFillMode.backwards
            rotateAnimation.setValue(targetRotation, forKeyPath: "transform.rotation")
            triangleLayer.add(rotateAnimation, forKey: nil)

            let positionAnimation = CAKeyframeAnimation(keyPath: "position")
            let animationPositionChangeVector = self.animationPositionChangeVector(withDirection: direction)
            let controlPointRandomRange = min(self.bounds.width, self.bounds.height) / 3.0
            let path = UIBezierPath()
            path.move(to: triangleLayer.position)
            let targetPoint = CGPoint(x: triangleLayer.position.x + animationPositionChangeVector.x + CGFloat.random(between: -20, and: 20),
                                      y: triangleLayer.position.y + animationPositionChangeVector.y + CGFloat.random(between: -20, and: 20))
            let controlPoint1 = CGPoint(x: triangleLayer.position.x + CGFloat.random(between: -controlPointRandomRange, and: controlPointRandomRange),
                                        y: triangleLayer.position.y + CGFloat.random(between: -controlPointRandomRange, and: controlPointRandomRange))
            let controlPoint2 = CGPoint(x: targetPoint.x + CGFloat.random(between: -controlPointRandomRange, and: controlPointRandomRange),
                                        y: targetPoint.y + CGFloat.random(between: -controlPointRandomRange, and: controlPointRandomRange))
            path.addCurve(to: targetPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            positionAnimation.path = path.cgPath;
            positionAnimation.duration = animationDuration + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            positionAnimation.beginTime = animationBeginTime + CFTimeInterval(CGFloat.random(between: -animationTimingRandomFactor, and: animationTimingRandomFactor))
            positionAnimation.fillMode = CAMediaTimingFillMode.backwards
            positionAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            triangleLayer.position = targetPoint
            triangleLayer.add(positionAnimation, forKey:nil)

        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + maxAnimationBeginTime + animationDuration + 2.0 * Double(animationTimingRandomFactor)) {
            triangleLayers.forEach { $0.removeFromSuperlayer() }
            completion?()
        }

        initialSublayers.forEach { (layer) in
            layer.opacity = 0.0
        }

        self.contents = nil
        self.backgroundColor = UIColor.clear.cgColor
        self.masksToBounds = false
    }

    private func snapshot() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        self.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image?.cgImage
    }

    private func animationPositionChangeVector(withDirection direction: DisintegrationDirection) -> CGPoint {
        let point = CGPoint(x: 0, y: min(self.bounds.width, self.bounds.height))
        switch direction {
        case .up:
            return point.applying(CGAffineTransform(rotationAngle: CGFloat.pi))
        case .down:
            return point
        case .left:
            return point.applying(CGAffineTransform(rotationAngle: CGFloat.pi / 2.0))
        case .right:
            return point.applying(CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0))
        case .lowerLeft:
            return point.applying(CGAffineTransform(rotationAngle: CGFloat.pi / 4.0))
        case .lowerRight:
            return point.applying(CGAffineTransform(rotationAngle: -CGFloat.pi / 4.0))
        case .upperLeft:
            return point.applying(CGAffineTransform(rotationAngle: 3.0 * CGFloat.pi / 4.0))
        case .upperRight:
            return point.applying(CGAffineTransform(rotationAngle: -3.0 * CGFloat.pi / 4.0))
        }
    }

    func getRandomTriangles(direction: DisintegrationDirection,
                                    estimatedTrianglesCount: Int,
                                    completion: @escaping ([Triangle]) -> ()) {
        DispatchQueue.global(qos: .background).async {
            // We generate the random triangles by first dividing the bounds of the layer into a grid. Every cell of the grid
            // has 4 random points: on top, on the bottom, on the left, and on the right. Connecting those points in a random
            // way creates a triangulation of the layer.

            var numberOfRows: Int, numberOfColumns: Int
            if self.bounds.width < self.bounds.height {
                numberOfColumns = Int(sqrt(CGFloat(estimatedTrianglesCount - 2) * self.bounds.width / 4.0 / self.bounds.height))
                numberOfRows = Int(CGFloat(numberOfColumns) * self.bounds.height / self.bounds.width)
            } else {
                numberOfRows = Int(sqrt(CGFloat(estimatedTrianglesCount - 2) * self.bounds.height / 4.0 / self.bounds.width))
                numberOfColumns = Int(CGFloat(numberOfRows) * self.bounds.width / self.bounds.height)
            }

            let cellSize = CGSize(width: self.bounds.width / CGFloat(numberOfColumns), height: self.bounds.height / CGFloat(numberOfRows))
            let xRandomFactor = cellSize.width / 4.0
            let yRandomFactor = cellSize.height / 4.0

            struct Cell {
                var top, bottom, left, right: CGPoint
            }

            var points = Array(repeating: Array(repeating: Cell(top: .zero, bottom: .zero, left: .zero, right: .zero), count: numberOfColumns),
                               count: numberOfRows)

            for row in 0..<numberOfRows {
                for column in 0..<numberOfColumns {
                    points[row][column].top = row == 0 ? CGPoint(x: (CGFloat(column) + 0.5) * cellSize.width + CGFloat.random(between: -xRandomFactor, and: xRandomFactor),
                                                                 y: CGFloat(row) * cellSize.height)
                                                       : points[row - 1][column].bottom

                    points[row][column].left = column == 0 ? CGPoint(x: CGFloat(column) * cellSize.width,
                                                                     y: (CGFloat(row) + 0.5) * cellSize.height + CGFloat.random(between: -yRandomFactor, and: yRandomFactor))
                                                           : points[row][column - 1].right

                    let bottomX = (CGFloat(column) + 0.5) * cellSize.width + CGFloat.random(between: -xRandomFactor, and: xRandomFactor)
                    let bottomY = CGFloat(row + 1) * cellSize.height + (row == numberOfRows - 1 ? 0.0 : CGFloat.random(between: -yRandomFactor, and: yRandomFactor))
                    points[row][column].bottom = CGPoint(x: bottomX, y: bottomY)

                    let rightX = CGFloat(column + 1) * cellSize.width + (column == numberOfColumns - 1 ? 0.0 : CGFloat.random(between: -xRandomFactor, and: xRandomFactor))
                    let rightY = (CGFloat(row) + 0.5) * cellSize.height + CGFloat.random(between: -yRandomFactor, and: yRandomFactor)
                    points[row][column].right = CGPoint(x: rightX, y: rightY)
                }
            }

            var triangles = [Triangle(vertices: (.zero, points[0][0].top, points[0][0].left)),
                             Triangle(vertices: (CGPoint(x: 0, y: self.bounds.height), points[numberOfRows - 1][0].left, points[numberOfRows - 1][0].bottom)),
                             Triangle(vertices: (CGPoint(x: self.bounds.width, y: 0), points[0][numberOfColumns - 1].top, points[0][numberOfColumns - 1].right)),
                             Triangle(vertices: (CGPoint(x: self.bounds.width, y: self.bounds.height), points[numberOfRows - 1][numberOfColumns - 1].bottom, points[numberOfRows - 1][numberOfColumns - 1].right))]

            for row in 0..<numberOfRows {
                for column in 0..<numberOfColumns {
                    if arc4random() % 2 == 0 {
                        triangles.append(contentsOf: [Triangle(vertices: (points[row][column].top, points[row][column].left, points[row][column].bottom)),
                                                      Triangle(vertices: (points[row][column].top, points[row][column].right, points[row][column].bottom))])
                    } else {
                        triangles.append(contentsOf: [Triangle(vertices: (points[row][column].top, points[row][column].left, points[row][column].bottom)),
                                                      Triangle(vertices: (points[row][column].top, points[row][column].right, points[row][column].bottom))])
                    }
                }
            }

            for column in 1..<numberOfColumns {
                triangles.append(contentsOf: [Triangle(vertices: (points[0][column - 1].top, points[0][column - 1].right, points[0][column].top)),
                                              Triangle(vertices: (points[numberOfRows - 1][column - 1].bottom, points[numberOfRows - 1][column - 1].right, points[numberOfRows - 1][column].bottom))])

                for row in 1..<numberOfRows {
                    if arc4random() % 2 == 0 {
                        triangles.append(contentsOf: [Triangle(vertices: (points[row - 1][column - 1].right, points[row - 1][column - 1].bottom, points[row][column - 1].right)),
                                                      Triangle(vertices: (points[row - 1][column - 1].right, points[row - 1][column].bottom, points[row][column].left))])
                    } else {
                        triangles.append(contentsOf: [Triangle(vertices: (points[row - 1][column - 1].right, points[row - 1][column - 1].bottom, points[row - 1][column].bottom)),
                                                      Triangle(vertices: (points[row][column - 1].top, points[row][column - 1].right, points[row][column].top))])
                    }
                }
            }

            for row in 1..<numberOfRows {
                triangles.append(contentsOf: [Triangle(vertices: (points[row - 1][0].left, points[row - 1][0].bottom, points[row][0].left)),
                                              Triangle(vertices: (points[row - 1][numberOfColumns - 1].right, points[row - 1][numberOfColumns - 1].bottom, points[row][numberOfColumns - 1].right))])
            }

            let sortedTriangles = triangles.sorted(by: { (triangleA, triangleB) -> Bool in
                switch direction {
                case .up:
                    return triangleA.center.y < triangleB.center.y
                case .down:
                    return triangleA.center.y > triangleB.center.y
                case .left:
                    return triangleA.center.x < triangleB.center.x
                case .right:
                    return triangleA.center.x > triangleB.center.x
                case .lowerLeft:
                    let targetPoint = CGPoint(x: 0, y: self.bounds.height)
                    return triangleA.center.distance(to: targetPoint) < triangleB.center.distance(to: targetPoint)
                case .lowerRight:
                    let targetPoint = CGPoint(x: self.bounds.width, y: self.bounds.height)
                    return triangleA.center.distance(to: targetPoint) < triangleB.center.distance(to: targetPoint)
                case .upperLeft:
                    let targetPoint = CGPoint(x: 0, y: 0)
                    return triangleA.center.distance(to: targetPoint) < triangleB.center.distance(to: targetPoint)
                case .upperRight:
                    let targetPoint = CGPoint(x: self.bounds.width, y: 0)
                    return triangleA.center.distance(to: targetPoint) < triangleB.center.distance(to: targetPoint)
                }
            })

            completion(sortedTriangles)
        }
    }

}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - self.x), 2) + pow((point.y - self.y), 2))
    }
}

private extension CGFloat {
    static func random(between a: CGFloat, and b: CGFloat) -> CGFloat {
        return a + CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * (b - a)
    }
}
