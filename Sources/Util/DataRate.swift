//
//  DataRate.swift
//  SRTHaishinKit
//
//  Created by 立宣于 on 2023/10/11.
//

import Foundation

public struct DataRate {
    public let bitsPerSecond: Int

    init(kbps: Double) {
        bitsPerSecond = Int(kbps * Prefix.kilo)
    }

    init(mbps: Double) {
        bitsPerSecond = Int(mbps * Prefix.mega)
    }

    init(gbps: Double) {
        bitsPerSecond = Int(gbps * Prefix.giga)
    }
}

public extension DataRate {
    var kbps: Double {
        changeToBase(Prefix.kilo)
    }

    var mbps: Double {
        changeToBase(Prefix.mega)
    }

    var gbps: Double {
        changeToBase(Prefix.giga)
    }
}

extension DataRate: CustomDebugStringConvertible {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }()

    public var debugDescription: String {
        "\(kbps) kb/s"
    }
}

private extension DataRate {
    func changeToBase(_ base: Double) -> Double {
        Double(bitsPerSecond) / base
    }

    enum Prefix {
        static let kilo: Double = 1000
        static let mega: Double = 1000 * kilo
        static let giga: Double = 1000 * mega
    }
}
