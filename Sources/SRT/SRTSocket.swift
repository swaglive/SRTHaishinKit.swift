import Foundation
import HaishinKit
import Logboard

protocol SRTSocketDelegate: AnyObject {
    func socket(_ socket: SRTSocket, status: SRT_SOCKSTATUS)
    func socket(_ socket: SRTSocket, incomingDataAvailabled data: Data, bytes: Int32)
}

final class SRTSocket {
    static let defaultOptions: [SRTSocketOption: Any] = [:]
    static let payloadSize: Int = 1316

    var timeout: Int = 0
    var options: [SRTSocketOption: Any] = [:]
    weak var delegate: SRTSocketDelegate?
    private(set) var isRunning: Atomic<Bool> = .init(false)
    private let lockQueue: DispatchQueue = .init(label: "com.haishinkit.SRTHaishinKit.SRTSocket.lock", qos: .userInitiated)
    private(set) var socket: SRTSOCKET = SRT_INVALID_SOCK
    private(set) var status: SRT_SOCKSTATUS = SRTS_INIT {
        didSet {
            guard status != oldValue else {
                return
            }
            delegate?.socket(self, status: status)
            switch status {
            case SRTS_INIT: // 1
                logger.trace("SRT Socket Init")
            case SRTS_OPENED:
                logger.info("SRT Socket opened")
            case SRTS_LISTENING:
                logger.trace("SRT Socket Listening")
            case SRTS_CONNECTING:
                logger.trace("SRT Socket Connecting")
            case SRTS_CONNECTED:
                logger.info("SRT Socket Connected")
            case SRTS_BROKEN:
                logger.warn("SRT Socket Broken")
                close()
            case SRTS_CLOSING:
                logger.trace("SRT Socket Closing")
            case SRTS_CLOSED:
                logger.info("SRT Socket Closed")
                stopRunning()
            case SRTS_NONEXIST:
                logger.warn("SRT Socket Not Exist")
            default:
                break
            }
        }
    }
    private let outgoingQueue: DispatchQueue = .init(label: "com.haishinkit.SRTHaishinKit.SRTSocket.outgoing", qos: .userInitiated)
    private let incomingQueue: DispatchQueue = .init(label: "com.haishinkit.SRTHaishinKit.SRTSocket.incoming", qos: .userInitiated)

    func connect(_ addr: sockaddr_in, options: [SRTSocketOption: Any] = SRTSocket.defaultOptions) throws {
        guard socket == SRT_INVALID_SOCK else {
            return
        }
        srt_startup()
        // prepare socket
        socket = srt_create_socket()
        if socket == SRT_ERROR {
            let error_message = String(cString: srt_getlasterror_str())
            logger.error(error_message)
            throw SRTError.illegalState(message: error_message)
        }
        self.options = options
        guard configure(.pre) else {
            return
        }
        // prepare connect
        var addr_cp = addr
        let stat = withUnsafePointer(to: &addr_cp) { ptr -> Int32 in
            let psa = UnsafeRawPointer(ptr).assumingMemoryBound(to: sockaddr.self)
            return srt_connect(socket, psa, Int32(MemoryLayout.size(ofValue: addr)))
        }
        if stat == SRT_ERROR {
            let error_message = String(cString: srt_getlasterror_str())
            logger.error(error_message)
            throw SRTError.illegalState(message: error_message)
        }
        guard configure(.post) else {
            return
        }
        if incomingBuffer.count < windowSizeC {
            incomingBuffer = .init(count: Int(windowSizeC))
        }
        startRunning()
    }

    private var windowSizeC: Int32 = 1024 * 4
    private var outgoingBuffer: [Data] = .init()
    private lazy var incomingBuffer: Data = .init(count: Int(windowSizeC))

    func doOutput(data: Data) {
        outgoingQueue.async {
            self.outgoingBuffer.append(contentsOf: data.chunk(SRTSocket.payloadSize))
            repeat {
                guard var data = self.outgoingBuffer.first else {
                    return
                }
                _ = self.sendmsg2(&data)
                self.outgoingBuffer.remove(at: 0)
            } while !self.outgoingBuffer.isEmpty
        }
    }

    func listen() {
        incomingQueue.async {
            repeat {
                let result = self.recvmsg()
                if 0 < result {
                    self.delegate?.socket(self, incomingDataAvailabled: self.incomingBuffer, bytes: result)
                }
            } while self.isRunning.value
        }
    }

    func close() {
        guard socket != SRT_INVALID_SOCK else {
            return
        }
        srt_close(socket)
        socket = SRT_INVALID_SOCK
    }

    func configure(_ binding: SRTSocketOption.Binding) -> Bool {
        let failures = SRTSocketOption.configure(socket, binding: binding, options: options)
        guard failures.isEmpty else {
            logger.error(failures); return false
        }
        return true
    }

    @inline(__always)
    private func sendmsg2(_ data: inout Data) -> Int32 {
        return data.withUnsafeBytes { pointer in
            guard let buffer = pointer.baseAddress?.assumingMemoryBound(to: CChar.self) else {
                return SRT_ERROR
            }
            return srt_sendmsg2(socket, buffer, Int32(data.count), nil)
        }
    }

    @inline(__always)
    private func recvmsg() -> Int32 {
        return incomingBuffer.withUnsafeMutableBytes { pointer in
            guard let buffer = pointer.baseAddress?.assumingMemoryBound(to: CChar.self) else {
                return SRT_ERROR
            }
            return srt_recvmsg(socket, buffer, windowSizeC)
        }
    }
}

extension SRTSocket: Running {
    // MARK: Running
    func startRunning() {
        lockQueue.async {
            self.isRunning.mutate { $0 = true }
            repeat {
                self.status = srt_getsockstate(self.socket)
                usleep(3 * 10000)
            } while self.isRunning.value
        }
    }

    func stopRunning() {
        lockQueue.async {
            self.isRunning.mutate { $0 = false }
        }
    }
}
