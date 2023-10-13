//
//  DataRate.swift
//  SRTHaishinKit
//
//  Created by 立宣于 on 2023/10/11.
//

import Foundation

public struct DataRate {
    public static let zero = DataRate(bitsPerSecond: 0)
    public static let kbps = DataRate(bitsPerSecond: 1 * Prefix.kilo)
    public static let mbps = DataRate(bitsPerSecond: 1 * Prefix.mega)
    public static let gbps = DataRate(bitsPerSecond: 1 * Prefix.giga)
    public let bitsPerSecond: Int

    public init(bitsPerSecond: Int) {
        self.bitsPerSecond = bitsPerSecond
    }
    
    public init(kbps: Double) {
        bitsPerSecond = Int(kbps * Prefix.fkilo)
    }

    public init(mbps: Double) {
        bitsPerSecond = Int(mbps * Prefix.fmega)
    }

    public init(gbps: Double) {
        bitsPerSecond = Int(gbps * Prefix.fgiga)
    }
}

extension DataRate: Comparable {
    public static func < (lhs: DataRate, rhs: DataRate) -> Bool {
        lhs.bitsPerSecond < rhs.bitsPerSecond
    }
}

public extension DataRate {
    static func + (lhs: DataRate, rhs: DataRate) -> DataRate {
        DataRate(bitsPerSecond: lhs.bitsPerSecond + rhs.bitsPerSecond)
    }
    
    static func - (lhs: DataRate, rhs: DataRate) -> DataRate {
        DataRate(bitsPerSecond: lhs.bitsPerSecond - rhs.bitsPerSecond)
    }
    
    static func * (lhs: DataRate, rhs: Double) -> DataRate {
        DataRate(bitsPerSecond: Int(Double(lhs.bitsPerSecond) * rhs))
    }
    
    static func * (lhs: Double, rhs: DataRate) -> DataRate {
        rhs * lhs
    }
    
    static func / (lhs: DataRate, rhs: Double) -> DataRate {
        DataRate(bitsPerSecond: Int(Double(lhs.bitsPerSecond) / rhs))
    }
}

public extension DataRate {
    var kbps: Double {
        changeToBase(Prefix.fkilo)
    }

    var mbps: Double {
        changeToBase(Prefix.fmega)
    }

    var gbps: Double {
        changeToBase(Prefix.fgiga)
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
        static let kilo: Int = 1000
        static let mega: Int = 1000 * kilo
        static let giga: Int = 1000 * mega
        static let fkilo: Double = 1000
        static let fmega: Double = 1000 * fkilo
        static let fgiga: Double = 1000 * fmega
    }
}
