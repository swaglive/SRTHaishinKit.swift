//
//  FrameRateCounter.swift
//  SRTHaishinKit
//
//  Created by 立宣于 on 2022/7/12.
//

import Foundation

public class FrameRateCounter {
    public private(set) var fps: Int = 0
    private var frames: Int = 0
    private var timer: Timer!

    public init() {
        let timer = Timer(timeInterval: 1, repeats: true, block: { [weak self] _ in
            self?.updateFps()
        })
        timer.tolerance = 0.001
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    deinit {
        timer.invalidate()
    }

    private func updateFps() {
        fps = frames
        frames = 0
    }

    public func accumulate() {
        DispatchQueue.main.async {
            self.frames += 1
        }
    }
}
