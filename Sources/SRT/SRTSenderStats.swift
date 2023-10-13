//
//  SRTSenderStats.swift
//  SRTHaishinKit
//
//  Created by 立宣于 on 2023/10/11.
//

import Foundation

public struct SRTSenderStats {
    init(_ stats: SRT_TRACEBSTATS) {
        dataRate = DataRate(mbps: stats.mbpsSendRate)
        estimatedBandwidth = DataRate(mbps: stats.mbpsBandwidth)
        bufferLevel = Int(stats.pktSndBuf)
        packetLoss = Int(stats.pktSndLoss)
        packetSent = Int(stats.pktSent)
        packetRetransmitted = Int(stats.pktRetrans)
    }
    
    public let dataRate: DataRate
    public let estimatedBandwidth: DataRate
    public let bufferLevel: Int
    public let packetLoss: Int
    public let packetSent: Int
    public let packetRetransmitted: Int
}
