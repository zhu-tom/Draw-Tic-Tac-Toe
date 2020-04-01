//
//  DrawView.swift
//  Assignment4
//
//  Created by Tom Zhu on 2020-03-23.
//  Copyright © 2020 COMP1601. All rights reserved.
//

import UIKit
import simd

class DrawView: UIView {
    var currentLine: Line?
    var finishedLines = [Line]()
    var intersections = [CGPoint]()
    var zones = [UIBezierPath]()
    var zoneCoords = [[CGPoint]](repeating: [CGPoint](), count: 9)
    var mTicTacToeGame = TicTacToeGame()
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func reset() {
        currentLine = nil
        finishedLines = [Line]()
        intersections = [CGPoint]()
        zones = [UIBezierPath]()
        zoneCoords = [[CGPoint]](repeating: [CGPoint](), count: 9)
        mTicTacToeGame.reset()
        for view in subviews {
            if view is UIImageView || view is UITextView {
                view.removeFromSuperview()
            }
        }
        setNeedsDisplay()
    }
    
    func strokeLine(line: Line) {
        let path = UIBezierPath()
        path.lineWidth = CGFloat(lineThickness);
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: line.begin);
        path.addLine(to: line.end);
        path.stroke();
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor.white
        
        finishedLineColor.setStroke()
        for line in finishedLines {
            strokeLine(line: line)
        }
        
        if let line = currentLine {
            currentLineColor.setStroke()
            strokeLine(line: line)
        }
        
        zones = [UIBezierPath]()
        if intersections.count == 4 {
            for zone in zoneCoords {
                addZone(points: zone)
            }
            for i in 0..<mTicTacToeGame.gameBoard.count {
                if mTicTacToeGame.gameBoard[i] != nil {
                    let image = UIImage(named: mTicTacToeGame.gameBoard[i] == "X" ? "x_img":"o_img")
                    let imageView = UIImageView(image: image!)
                    imageView.backgroundColor = UIColor.clear
                    
                    if mTicTacToeGame.winningLine != nil {
                        if mTicTacToeGame.winningLine!.contains(i) {
                            imageView.backgroundColor = UIColor.yellow
                        }
                    }
                    
                    imageView.frame = zones[i].cgPath.boundingBoxOfPath
                    addSubview(imageView)
                }
            }
            if mTicTacToeGame.isGameOver {
                let textView = UITextView(frame: CGRect(x: 20.0, y: 40.0, width: 300.0, height: 48.0))
                textView.text = "Tap anywhere to continue."
                textView.font = UIFont(name: "Helvetica Neue", size: 20)
                textView.textColor = UIColor.darkGray
                textView.backgroundColor = UIColor.clear
                
                addSubview(textView)
            }
        }
    }
    
    func getDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow(p1.x-p2.x, 2)+pow(p1.y-p2.y, 2))
    }
    
    func getIntersection(l1: Line, l2: Line) -> CGPoint? {
        let a = simd_double2x2(rows: [
            simd_double2(Double(l1.slope*(-1)), 1),
            simd_double2(Double(l2.slope*(-1)), 1)
        ])
        let b = simd_double2(Double(l1.yInt), Double(l2.yInt))
        if a.determinant != 0 {
            let solution = simd_mul(a.inverse, b)
            return CGPoint(x: solution.x, y: solution.y)
        } else {
            return nil
        }
    }
    
    func getClosest(to point: CGPoint, check: [CGPoint]) -> Int {
        var index = 0
        var closest = getDistance(p1: point, p2: check[0])
        for i in 1..<check.count {
            let dist = getDistance(p1: point, p2: check[i])
            if dist < closest {
                closest = dist
                index = i
            }
        }
        
        return index
    }
    
    func addZone(points: [CGPoint]) {
        UIColor.green.setStroke()
        UIColor.orange.setFill();
        
        let path = UIBezierPath()
        path.lineWidth = CGFloat(lineThickness);
        path.lineCapStyle = CGLineCap.round;
        
        path.move(to: points[0])
        for point in points[1...] {
            path.addLine(to: point)
        }
        
        path.close();
        //path.stroke();
        //path.fill();
        
        zones.append(path)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        
        if mTicTacToeGame.isGameOver {
            reset()
            return
        }
        
        let touch = touches.first!
        let location = touch.location(in: self)
        if finishedLines.count < 4 {
            currentLine = Line(begin: location, end: location)
        }
        
        var num = 0
        var index: Int? = nil
        for i in 0..<zones.count {
            if zones[i].contains(location) {
                num += 1
                index = i
            }
        }
        
        if index != nil && num == 1 {
            print(index!)
            mTicTacToeGame.play(square: index!)
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        let touch = touches.first!
        let location = touch.location(in: self)
        if finishedLines.count < 4 {
            if currentLine != nil {currentLine!.end = location}
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(#function)
        if finishedLines.count < 4 {
            for line in finishedLines {
                if let intersection = getIntersection(l1: line, l2: currentLine!) {
                    if intersection.x < UIScreen.main.bounds.width && intersection.x > 0 && intersection.y < UIScreen.main.bounds.height && intersection.y > 0 {
                        line.intersections.append((currentLine!, intersection))
                        currentLine!.intersections.append((line, intersection))
                        intersections.append(intersection)
                    }
                }
            }
            
            if currentLine != nil {finishedLines.append(currentLine!)}
            if finishedLines.count == 4 {
                if intersections.count > 4 {
                    reset()
                    return
                }
                let compare = finishedLines[0]
                var parallel: Line?
                
                for line in finishedLines {
                    line.intersections.sort(by: {(t1: (_:Line, at:CGPoint), t2: (_:Line, at: CGPoint)) -> Bool in
                        return getDistance(p1: line.begin, p2: t1.at) < getDistance(p1: line.begin, p2: t2.at)
                    })
                    
                    var intersects = false
                    for t in compare.intersections {
                        if line.slope == t.with.slope {
                            intersects = true
                        }
                    }
                    
                    if !intersects {
                        parallel = line
                    }
                }
                
                let pair1 = [compare, parallel!]
                let pair2 = [compare, compare.intersections[1].with]
                
                intersections.swapAt(2, 3)
                zoneCoords[4] = intersections

                currentLine = Line()
                
                addCornerCoords(from: 0, line: pair1[0], at: 0)
                addCornerCoords(from: 1, line: pair1[0], at: 2)
                
                var closestIndex = getClosest(to: pair1[0].begin, check: [pair1[1].begin, pair1[1].end])
                var options = [6, 8]
                var num = options.remove(at: closestIndex)
                addCornerCoords(from: 0, line: pair1[1], at: num)
                addCornerCoords(from: 1, line: pair1[1], at: options[0])
                
                addSideCords(from: 0, line: pair2[0], at: 3)
                addSideCords(from: 1, line: pair2[0], at: 5)
                
                closestIndex = getClosest(to: pair2[0].begin, check: [pair2[1].begin, pair2[1].end])
                options = [1, 7]
                num = options.remove(at: closestIndex)
                addSideCords(from: 0, line: pair2[1], at: num)
                addSideCords(from: 1, line: pair2[1], at: options[0])
                setNeedsDisplay()
            }
        }
    }
    
    func addSideCords(from num: Int, line: Line, at i: Int) {
        let startFrom: CGPoint
        if num == 0 {
            startFrom = line.begin
        } else {
            startFrom = line.end
        }
        
        var points = [CGPoint]()
        points.append(startFrom)
        points.append(line.intersections[num].at)
        for (intLine, point) in line.intersections[num].with.intersections {
            if point != line.intersections[num].at {
                points.append(point)
                let lineBegEnd = [intLine.begin, intLine.end]
                let index = intLine.intersections.firstIndex(where: {(t1: (_: Line, p1: CGPoint)) -> Bool in
                    return t1.p1 == point
                })!
                
                points.append(lineBegEnd[index])
                
                break
            }
        }
        
        zoneCoords[i] = points
    }
    
    func addCornerCoords(from num: Int, line: Line, at i: Int) {
        let startFrom: CGPoint
        if num == 0 {
            startFrom = line.begin
        } else {
            startFrom = line.end
        }
        
        var points = [CGPoint]()
        points.append(startFrom)
        let closest = line.intersections[num].at
        points.append(closest)
        
        let otherBeginEnd = [line.intersections[num].with.begin, line.intersections[num].with.end]
        
        let index = line.intersections[num].with.intersections.firstIndex(where: {(t1: (with: Line, _: CGPoint)) -> Bool in
            return line.slope == t1.with.slope && line.yInt == t1.with.yInt
        })!
        
        points.append(otherBeginEnd[index])
        
        let deltaX = otherBeginEnd[index].x - closest.x
        let deltaY = otherBeginEnd[index].y - closest.y
        
        points.append(CGPoint(x: startFrom.x + deltaX, y: startFrom.y + deltaY))
        zoneCoords[i] = points
    }
}

