//
//  Line.swift
//  Assignment4
//
//  Created by Tom Zhu on 2020-03-23.
//  Copyright © 2020 COMP1601. All rights reserved.
//

import Foundation
import CoreGraphics

class Line {
    var begin: CGPoint
    var end: CGPoint {
        didSet {
            slope = (begin.y - end.y)/(begin.x - end.x)
            yInt = begin.y - (slope*begin.x)
        }
    }
    var slope: CGFloat
    var yInt: CGFloat
    var intersections: [(with: Line, at: CGPoint)]
    
    init() {
        begin = CGPoint.zero
        end = CGPoint.zero
        slope = CGFloat.zero
        yInt = CGFloat.zero
        intersections = [(Line, CGPoint)]()
    }
    
    init(begin: CGPoint, end: CGPoint) {
        self.begin = begin
        self.end = end
        slope = (begin.y - end.y)/(begin.x - end.x)
        yInt = begin.y - (slope*begin.x)
        intersections = [(Line, CGPoint)]()
    }
    
//    func calcSlope() -> CGFloat {
//        return (begin.y - end.y)/(begin.x - end.x)
//    }
//    
//    func calcYInt() -> CGFloat {
//        slope = calcSlope()
//        return begin.y - (slope*begin.x)
//    }
}
