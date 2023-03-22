import Logboard

let logger = LBLogger.with("com.haishinkit.SRTHaishinKit")

public struct SRTNotificationNames {
    public static let connectionStatusNotification = Notification.Name(rawValue: "com.haishinkit.SRTHaishinKit.SRTConnectionStatusNotification")

    public static let streamStatusNotification = Notification.Name(rawValue: "com.haishinkit.SRTHaishinKit.SRTStreamStatusNotification")
}

public struct SRTNotificationProperties {
    public static let status = "status"
}
