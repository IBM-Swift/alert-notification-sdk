//
//  Alert.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

public class Alert {
    /*
     * Internally defined classes.
     */
    public struct URL {
        public let description: String
        public let URL: String
        public init(description: String, URL: String) {
            self.description = description
            self.URL = URL
        }
    }
    
    public struct Detail {
        public let name: String
        public let value: String
        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }
    
    public struct EmailMessage {
        public let subject: String
        public let body: String
        public init(subject: String, body: String) {
            self.subject = subject
            self.body = body
        }
    }
    
    public enum Severity: Int {
        case clear = 0, indeterminate, warning, minor, major, critical, fatal
    }
    
    public enum Status: String {
        case problem, acknowledged, resolved
    }
    
    public enum NotificationState: String {
        case unnotified, notified, acknowledged, archived, escalated
    }
    
    /*
     * Instance variables.
     */
    
    // Required variables.
    public let summary: String
    public let location: String
    public let severity: Severity
    
    // Optional variables.
    public private(set) var id: String?
    public private(set) var shortId: String?
    public private(set) var date: Date?
    public private(set) var status: Status?
    public private(set) var source: String?
    public private(set) var applicationsOrServices: [String]?
    public private(set) var URLs: [Alert.URL]?
    public private(set) var details: [Detail]?
    public private(set) var emailMessageToSend: EmailMessage?
    public private(set) var SMSMessageToSend: String?
    public private(set) var voiceMessageToSend: String?
    public private(set) var notificationState: NotificationState?
    public private(set) var firstOccurrence: Date?
    public private(set) var lastNotified: Date?
    public private(set) var internalTime: Date?
    public private(set) var expired: Bool?
    
    /*
     * Builder.
     */
    public class Builder {
        private var summary: String?
        private var location: String?
        private var severity: Severity?
        private var id: String?
        private var date: Date?
        private var status: Status?
        private var source: String?
        private var applicationsOrServices: [String]?
        private var URLs: [Alert.URL]?
        private var details: [Detail]?
        private var emailMessageToSend: EmailMessage?
        private var SMSMessageToSend: String?
        private var voiceMessageToSend: String?
        
        public init() {
            
        }
        
        public init(from alert: Alert) {
            self.summary = alert.summary
            self.location = alert.location
            self.severity = alert.severity
            self.id = alert.id
            self.date = alert.date
            self.status = alert.status
            self.source = alert.source
            self.applicationsOrServices = alert.applicationsOrServices
            self.URLs = alert.URLs
            self.details = alert.details
            self.emailMessageToSend = alert.emailMessageToSend
            self.SMSMessageToSend = alert.SMSMessageToSend
            self.voiceMessageToSend = alert.voiceMessageToSend
        }
        
        public func setSummary(_ summary: String) -> Builder {
            self.summary = summary
            return self
        }
        
        public func setLocation(_ location: String) -> Builder {
            self.location = location
            return self
        }
        
        public func setSeverity(_ severity: Severity) -> Builder {
            self.severity = severity
            return self
        }
        
        public func setID(_ id: String) -> Builder {
            self.id = id
            return self
        }
        
        public func setDate(_ date: Date) -> Builder {
            self.date = date
            return self
        }
        
        public func setDate(fromString date: String) throws -> Builder {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let date: Date = dateFormatter.date(from: date) else {
                throw AlertNotificationError.alertError("Invalid String format for variable \"date\". Correct format is yyyy-MM-dd HH:mm:ss")
            }
            return self.setDate(date)
        }
        
        public func setDate(fromIntInMilliseconds date: Int) -> Builder {
            let date: Date = Date(timeIntervalSince1970: (Double(date)/1000.0) as TimeInterval)
            return self.setDate(date)
        }
        
        public func setStatus(_ status: Status) -> Builder {
            self.status = status
            return self
        }
        
        public func setSource(_ source: String) -> Builder {
            self.source = source
            return self
        }
        
        public func setApplicationsOrServices(_ apps: [String]) -> Builder {
            self.applicationsOrServices = apps
            return self
        }
        
        public func setURLs(_ URLs: [Alert.URL]) -> Builder {
            self.URLs = URLs
            return self
        }
        
        public func setDetails(_ details: [Detail]) -> Builder {
            self.details = details
            return self
        }
        
        public func setEmailMessageToSend(_ email: EmailMessage) -> Builder {
            self.emailMessageToSend = email
            return self
        }
        
        public func setSMSMessageToSend(_ SMS: String) -> Builder {
            self.SMSMessageToSend = SMS
            return self
        }
        
        public func setVoiceMessageToSend(_ voice: String) -> Builder {
            self.voiceMessageToSend = voice
            return self
        }
        
        public func build() throws -> Alert {
            guard let summary = self.summary else {
                throw AlertNotificationError.alertError("Cannot build Alert object without value for variable  \"summary\".")
            }
            guard let location = self.location else {
                throw AlertNotificationError.alertError("Cannot build Alert object without value for variable  \"location\".")
            }
            guard let severity = self.severity else {
                throw AlertNotificationError.alertError("Cannot build Alert object without value for variable  \"severity\".")
            }
            return Alert(summary: summary, location: location, severity: severity, id: self.id, date: self.date, status: self.status, source: self.source, applicationsOrServices: self.applicationsOrServices, URLs: self.URLs, details: self.details, emailMessageToSend: self.emailMessageToSend, SMSMessageToSend: self.SMSMessageToSend, voiceMessageToSend: self.voiceMessageToSend)
        }
    }
    
    /*
     * Initializers.
     */
    
    // Base initializer.
    private init(summary: String, location: String, severity: Severity, id: String? = nil, date: Date? = nil, status: Status? = nil, source: String? = nil, applicationsOrServices: [String]? = nil, URLs: [Alert.URL]? = nil, details: [Detail]? = nil, emailMessageToSend: EmailMessage? = nil, SMSMessageToSend: String? = nil, voiceMessageToSend: String? = nil) {
        
        self.summary = summary
        self.location = location
        self.severity = severity
        self.id = id
        self.date = date
        self.status = status
        self.source = source
        self.applicationsOrServices = applicationsOrServices
        self.URLs = URLs
        self.details = details
        self.emailMessageToSend = emailMessageToSend
        self.SMSMessageToSend = SMSMessageToSend
        self.voiceMessageToSend = voiceMessageToSend
    }
    
    // JSON initializer.
    init?(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any] {
            // Mandatory properties.
            if let summary = dictionary["What"] as? String {
                self.summary = summary
            } else {
                return nil
            }
            if let location = dictionary["Where"] as? String {
                self.location = location
            } else {
                return nil
            }
            if let severity = dictionary["Severity"] as? String, let sevValue = Alert.getSeverity(from: severity) {
                self.severity = sevValue
            } else if let severity = dictionary["Severity"] as? Int, let sevValue = Severity(rawValue: severity) {
                self.severity = sevValue
            } else {
                return nil
            }
            
            // Optional properties.
            if let id = dictionary["Identifier"] as? String {
                self.id = id
            }
            if let shortId = dictionary["ShortId"] as? String {
                self.shortId = shortId
            }
            if let date = dictionary["When"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.date = dateFormatter.date(from: date)
            } else if let date = dictionary["When"] as? Int {
                self.date = Date(timeIntervalSince1970: (Double(date)/1000.0) as TimeInterval)
            }
            if let status = dictionary["Type"] as? String, let statusValue = Status(rawValue: status.lowercased()) {
                self.status = statusValue
            }
            if let source = dictionary["Source"] as? String {
                self.source = source
            }
            if let apps = dictionary["ApplicationsOrServices"] as? [String] {
                self.applicationsOrServices = apps
            }
            if let URLs = dictionary["URLs"] as? [[String: String]] {
                var URLarray = Array<Alert.URL>()
                for alertURL in URLs {
                    if let description = alertURL["Description"], let URLvalue = alertURL["URL"] {
                        URLarray.append(Alert.URL(description: description, URL: URLvalue))
                    }
                }
                self.URLs = URLarray
            }
            if let details = dictionary["Details"] as? [[String: String]] {
                var detailArray = [Detail]()
                for detail in details {
                    if let name = detail["Name"], let value = detail["Value"] {
                        detailArray.append(Detail(name: name, value: value))
                    }
                }
                self.details = detailArray
            }
            if let email = dictionary["EmailMessageToSend"] as? [String: String], let subject = email["Subject"], let body = email["Body"] {
                self.emailMessageToSend = EmailMessage(subject: subject, body: body)
            }
            if let SMS = dictionary["SMSMessageToSend"] as? String {
                self.SMSMessageToSend = SMS
            }
            if let voice = dictionary["VoiceMessageToSend"] as? String {
                self.voiceMessageToSend = voice
            }
            if let notificationState = dictionary["NotificationState"] as? String, let notValue = NotificationState(rawValue: notificationState.lowercased()) {
                self.notificationState = notValue
            }
            if let firstOccurrence = dictionary["FirstOccurrence"] as? Int {
                self.firstOccurrence = Date(timeIntervalSince1970: (Double(firstOccurrence)/1000.0) as TimeInterval)
            }
            if let lastNotified = dictionary["LastNotified"] as? Int {
                self.lastNotified = Date(timeIntervalSince1970: (Double(lastNotified)/1000.0) as TimeInterval)
            }
            if let internalTime = dictionary["InternalTime"] as? Int {
                self.internalTime = Date(timeIntervalSince1970: (Double(internalTime)/1000.0) as TimeInterval)
            }
            if let expired = dictionary["Expired"] as? Bool {
                self.expired = expired
            }
        } else {
            return nil
        }
    }
    
    /*
     * Instance functions.
     */
    
    // Convert this alert's contents to a JSON data object.
    func toJSONData() throws -> Data? {
        var postDict: Dictionary<String, Any> = Dictionary<String, Any>()
        postDict["What"] = self.summary
        postDict["Where"] = self.location
        postDict["Severity"] = self.severity.rawValue
        if let alertId = self.id {
            postDict["Identifier"] = alertId
        }
        if let shortId = self.shortId {
            postDict["ShortId"] = shortId
        }
        if let alertDate = self.date {
            postDict["When"] = Int(alertDate.timeIntervalSince1970 * 1000.0)
        }
        if let alertStatus = self.status {
            postDict["Type"] = alertStatus.rawValue.capitalized
        }
        if let alertSource = self.source {
            postDict["Source"] = alertSource
        }
        if let alertApps = self.applicationsOrServices {
            postDict["ApplicationsOrServices"] = alertApps
        }
        if let alertURLs = self.URLs {
            var dataURLs = [Dictionary<String, String>]()
            for item in alertURLs {
                dataURLs.append(["Description": "\(item.description)", "URL": "\(item.URL)"])
            }
            postDict["URLs"] = dataURLs
        }
        if let alertDetails = self.details {
            var dataDetails = [Dictionary<String, String>]()
            for item in alertDetails {
                dataDetails.append(["Name": "\(item.name)", "Value": "\(item.value)"])
            }
            postDict["Details"] = dataDetails
        }
        if let alertEmail = self.emailMessageToSend {
            postDict["EmailMessageToSend"] = ["Subject": "\(alertEmail.subject)", "Body": "\(alertEmail.body)"]
        }
        if let alertSMS = self.SMSMessageToSend {
            postDict["SMSMessageToSend"] = alertSMS
        }
        if let alertVoice = self.voiceMessageToSend {
            postDict["VoiceMessageToSend"] = alertVoice
        }
        if let notState = self.notificationState {
            postDict["NotificationState"] = notState.rawValue.capitalized
        }
        if let firstOccurrence = self.firstOccurrence {
            postDict["FirstOccurrence"] = Int(firstOccurrence.timeIntervalSince1970 * 1000.0)
        }
        if let lastNotified = self.lastNotified {
            postDict["LastNotified"] = Int(lastNotified.timeIntervalSince1970 * 1000.0)
        }
        if let internalTime = self.internalTime {
            postDict["InternalTime"] = Int(internalTime.timeIntervalSince1970 * 1000.0)
        }
        if let expired = self.expired {
            postDict["Expired"] = expired
        }
        
        return try JSONSerialization.data(withJSONObject: postDict, options: [])
    }
    
    /*
     * Class functions.
     */
    class func getSeverity(from str: String) -> Severity? {
        switch str.lowercased() {
        case "fatal": return .fatal
        case "critical": return .critical
        case "major": return .major
        case "minor": return .minor
        case "warning": return .warning
        case "indeterminate": return .indeterminate
        case "clear": return .clear
        default: return nil
        }
    }
}
