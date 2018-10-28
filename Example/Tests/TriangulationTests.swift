// https://github.com/Quick/Quick

import Quick
import Nimble

@testable import Disintegrate

extension Triangle {

    var area: CGFloat {
        return abs(self.vertices.0.x * (self.vertices.1.y - self.vertices.2.y) +
                   self.vertices.1.x * (self.vertices.2.y - self.vertices.0.y) +
                   self.vertices.2.x * (self.vertices.0.y - self.vertices.1.y)) / 2.0
    }

}

class TriangulationSpec: QuickSpec {

    override func spec() {
        describe("Random view triangulation") {

            for _ in 0 ..< 200 {
                let randomFrame = CGRect(x: CGFloat.random(in: 0 ..< 414),
                                         y: CGFloat.random(in: 0 ..< 896),
                                         width: CGFloat.random(in: 44 ..< 1000),
                                         height: CGFloat.random(in: 44 ..< 1000))
                let randomFrameArea = randomFrame.width * randomFrame.height
                let view = UIView(frame: randomFrame)
                for _ in 0 ..< 5 {
                    let trianglesCount = Int.random(in: 100 ..< 400)
                    it("rectangle with frame \(randomFrame) has the same area after dividing into \(trianglesCount) triangles") {
                        waitUntil { done in
                            view.layer.getRandomTriangles(direction: .random(),
                                                          estimatedTrianglesCount: trianglesCount,
                                                          completion: { (triangles) in
                                let trianglesAreaSum = triangles.map({ $0.area }).reduce(0, +)
                                expect(trianglesAreaSum).to(beCloseTo(randomFrameArea, within: 0.01))
                                done()
                            })
                        }
                    }
                }
            }

        }
    }

}
