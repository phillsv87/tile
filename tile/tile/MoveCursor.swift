//
//  MoveCursor.swift
//  tile
//
//  Created by Phillip Vance on 12/27/21.
//

import Cocoa
import Foundation

class MoveCursor {
    var moveCount: CGFloat = 10.0

    let diffPosition: CGPoint
    var currentPosition: CGPoint
    var timer: Timer?

    init(_ fromLocation: CGPoint, _ toLocation: CGPoint) {
        self.currentPosition = fromLocation
        self.diffPosition = CGPoint(
            x: (toLocation.x - self.currentPosition.x) / self.moveCount,
            y: (toLocation.y - self.currentPosition.y) / self.moveCount
        )

        self.timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(MoveCursor.timerUpdate), userInfo: nil, repeats: true)
    }

    @objc func timerUpdate() {
        if self.moveCount == 0 {
            self.timer?.invalidate()
            return
        }
        self.moveCount -= 1
        self.currentPosition.x += self.diffPosition.x
        self.currentPosition.y += self.diffPosition.y
        CGDisplayMoveCursorToPoint(0, self.currentPosition)
    }
}
