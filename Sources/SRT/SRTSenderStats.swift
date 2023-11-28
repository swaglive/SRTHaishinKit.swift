//
//  SRTSenderStats.swift
//  SRTHaishinKit
//
//  Created by 立宣于 on 2023/10/11.
//

import Foundation
import SRTIncludes

public struct SRTSenderStats {
    init(_ stats: SRT_TRACEBSTATS) {
        dataRate = DataRate(mbps: stats.mbpsSendRate)
        estimatedBandwidth = DataRate(mbps: stats.mbpsBandwidth)
        bufferLevel = Int(stats.byteSndBuf)
        packetLoss = Int(stats.pktSndLoss)
        packetSent = Int(stats.pktSent)
        packetRetransmitted = Int(stats.pktRetrans)
        // Ref: https://github.com/Haivision/srt/blob/master/docs/API/statistics.md#pktsentuniquetotal
        packetSentUnique = packetSent - packetRetransmitted
        packetDrop = Int(stats.pktSndDrop)
        packetRecvACK = Int(stats.pktRecvACK)
        packetRecvNAK = Int(stats.pktRecvNAK)
        bufferDelayMs = Int(stats.msSndBuf)
        bytesSent = Int(stats.byteSent)
        bytesRetransmitted = Int(stats.byteRetrans)
        bytesSentUnique = bytesSent - bytesRetransmitted
    }

    public let dataRate: DataRate
    public var estimatedUniqueDataRate: DataRate {
        bytesSent == 0 ? .zero : dataRate * (Double(bytesSentUnique) / Double(bytesSent))
    }

    public let estimatedBandwidth: DataRate
    public let bufferLevel: Int
    public let bufferDelayMs: Int
    public let bytesSent: Int
    public let bytesRetransmitted: Int
    public let bytesSentUnique: Int
    public let packetLoss: Int
    public let packetSent: Int
    public let packetDrop: Int
    public let packetRetransmitted: Int
    public let packetSentUnique: Int
    public let packetRecvACK: Int
    public let packetRecvNAK: Int
}
