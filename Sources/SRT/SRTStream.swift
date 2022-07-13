import AVFoundation
import Foundation
import HaishinKit

open class SRTStream: NetStream {
    public enum ReadyState: UInt8 {
        case initialized = 0
        case open = 1
        case play = 2
        case playing = 3
        case publish = 4
        case publishing = 5
        case closed = 6
    }

    private weak var connection: SRTConnection?
    private var name: String?
    private var delayedPublish: (() -> Void)?

    private lazy var tsWriter: TSWriter = {
        var tsWriter = TSWriter()
        tsWriter.delegate = self
        return tsWriter
    }()

    private let fpsCounter = FrameRateCounter()
    public var fps: Int {
        fpsCounter.fps
    }

    public private(set) var readyState: ReadyState = .initialized {
        didSet {
            guard oldValue != readyState else { return }
            switch oldValue {
            case .publishing:
                tsWriter.stopRunning()
                mixer.stopEncoding()
            default:
                break
            }

            switch readyState {
            case .publish:
                mixer.startEncoding(delegate: self)
                mixer.startRunning()
                tsWriter.startRunning()
                readyState = .publishing
            default:
                break
            }
            NotificationCenter.default.post(
                name: SRTNotificationNames.streamStatusNotification,
                object: self,
                userInfo: [SRTNotificationProperties.status: readyState]
            )
        }
    }

    public init(_ connection: SRTConnection) {
        super.init()
        self.connection = connection
        connection.attachStream(self)
    }

    /*
     Original implementation has strong circular reference issue.
     1. Streams depend on connected state of connection for changing publish
     2. Connection serves as a manager of streams to simplify API
     */
    func connectionDidUpdateConnected(_ connection: SRTConnection) {
        guard self.connection == connection else {
            return
        }
        if connection.connected {
            delayedPublish?()
            delayedPublish = nil
        } else {
            readyState = .open
        }
    }

    override open func attachCamera(_ camera: AVCaptureDevice?, onError: ((NSError) -> Void)? = nil) {
        if camera == nil {
            tsWriter.expectedMedias.remove(.video)
        } else {
            tsWriter.expectedMedias.insert(.video)
        }
        super.attachCamera(camera, onError: onError)
    }

    override open func attachAudio(_ audio: AVCaptureDevice?, automaticallyConfiguresApplicationAudioSession: Bool = true, onError: ((NSError) -> Void)? = nil) {
        if audio == nil {
            tsWriter.expectedMedias.remove(.audio)
        } else {
            tsWriter.expectedMedias.insert(.audio)
        }
        super.attachAudio(audio, automaticallyConfiguresApplicationAudioSession: automaticallyConfiguresApplicationAudioSession, onError: onError)
    }

    open func publish(_ name: String?) {
        lockQueue.async {
            guard name != nil else {
                switch self.readyState {
                case .publish, .publishing:
                    self.readyState = .open
                default:
                    break
                }
                return
            }
            if self.connection?.connected == true {
                self.readyState = .publish
            } else {
                self.delayedPublish = { [weak self] in self?.publish(name) }
            }
        }
    }

    open func close() {
        if readyState == .closed || readyState == .initialized {
            return
        }
        publish(nil)
        lockQueue.async {
            self.readyState = .closed
        }
    }
}

extension SRTStream: TSWriterDelegate {
    // MARK: TSWriterDelegate

    public func writer(_ writer: TSWriter, didOutput data: Data) {
        guard readyState == .publishing else { return }
        connection?.outgoingSocket?.write(data)
    }
}

extension SRTStream: AudioCodecDelegate {
    public func audioCodec(_ codec: HaishinKit.AudioCodec, didSet formatDescription: CMFormatDescription?) {
        tsWriter.audioCodec(codec, didSet: formatDescription)
    }

    public func audioCodec(_ codec: HaishinKit.AudioCodec, didOutput sample: UnsafeMutableAudioBufferListPointer, presentationTimeStamp: CMTime) {
        tsWriter.audioCodec(codec, didOutput: sample, presentationTimeStamp: presentationTimeStamp)
    }
}

extension SRTStream: VideoCodecDelegate {
    public func videoCodec(_ codec: VideoCodec, didSet formatDescription: CMFormatDescription?) {
        tsWriter.videoCodec(codec, didSet: formatDescription)
    }

    public func videoCodec(_ codec: VideoCodec, didOutput sampleBuffer: CMSampleBuffer) {
        tsWriter.videoCodec(codec, didOutput: sampleBuffer)
        fpsCounter.accumulate()
    }
}
