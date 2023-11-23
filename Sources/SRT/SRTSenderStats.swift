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
        bufferLevel = Int(stats.byteSndBuf)
        packetLoss = Int(stats.pktSndLoss)
        packetSent = Int(stats.pktSent)
        packetDrop = Int(stats.pktSndDrop)
        packetRecvACK = Int(stats.pktRecvACK)
        packetRecvNAK = Int(stats.pktRecvNAK)
        packetRetransmitted = Int(stats.pktRetrans)
        bufferDelayMs = Int(stats.msSndBuf)
    }
    
    public let dataRate: DataRate
    public let estimatedBandwidth: DataRate
    public let bufferLevel: Int
    public let bufferDelayMs: Int
    public let packetLoss: Int
    public let packetSent: Int
    public let packetDrop: Int
    public let packetRetransmitted: Int
    public let packetRecvACK: Int
    public let packetRecvNAK: Int
}
