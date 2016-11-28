//
//  Alert.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

class Alert {
    /*
     * Instance variables and functions.
     */
    
    var what: String
    var `where`: String
    var severity: Severity
    
    var id: String?
    var shortId: String? = nil
    var when: Date?
    var type: AlertType?
    var source: String?
    var applicationsOrServices: [String]?
    var URLs: [AlertURL]?
    var details: [Detail]?
    var emailMessageToSend: EmailMessage?
    var smsMessageToSend: String?
    var voiceMessageToSend: String?
    var notificationState: NotificationState? = nil
    var firstOccurrence: Date? = nil
    var lastNotified: Date? = nil
    var internalTime: Date? = nil
    var expired: Bool? = nil
    
    // Convert this alert's contents to a JSON data object.
    func postBody() -> Data? {
        var postDict: Dictionary<String, Any> = Dictionary<String, Any>()
        postDict["What"] = self.what
        postDict["Where"] = self.`where`
        postDict["Severity"] = self.severity.rawValue
        if let alertId = self.id {
            postDict["Identifier"] = alertId
        }
        if let alertWhen = self.when {
            if #available(OSX 10.12, *) {
                let formatter = ISO8601DateFormatter()
                postDict["When"] = formatter.string(from: alertWhen)
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                postDict["When"] = formatter.string(from: alertWhen)
            }
        }
        if let alertType = self.type {
            postDict["Type"] = alertType.rawValue
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
        if let alertSMS = self.smsMessageToSend {
            postDict["SMSMessageToSend"] = alertSMS
        }
        if let alertVoice = self.voiceMessageToSend {
            postDict["VoiceMessageToSend"] = alertVoice
        }
        
        do {
            return try JSONSerialization.data(withJSONObject: postDict, options: [])
        } catch _ {
            
        }
        
        return nil
    }
    
    // Create a POST request with this alert.
    func post(to alertURL: URL?, callback: ((Alert?, Error?) -> Void)?) throws -> URLSessionDataTask? {
        if alertURL == nil {
            throw AlertNotificationError.AlertError("No URL provided.")
        }
        
        let session: URLSession = URLSession.shared
        var request: URLRequest = URLRequest(url: alertURL!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let alertData = self.postBody() else {
            throw AlertNotificationError.AlertError("Invalid data in alert object.")
        }
        request.httpBody = alertData
        let postTask = session.dataTask(with: request) { (data, response, error) in
            if data == nil || error != nil {
                if callback != nil {
                    callback!(nil, error)
                }
                return
            }
            
            guard let alertResponse = Alert(data: data!) else {
                if callback != nil {
                    callback!(nil, AlertNotificationError.AlertError("Malformed response from server."))
                }
                return
            }
            
            if callback != nil {
                callback!(alertResponse, nil)
            }
        }
        
        postTask.resume()
        return postTask
    }
    
    // Same, but handle the case of being passed a string URL.
    func post(to alertURL: String, callback: ((Alert?, Error?) -> Void)?) throws -> URLSessionDataTask? {
        return try self.post(to: URL(string: alertURL), callback: callback)
    }
    
    /*
     * Initializers.
     */
    
    // Base initializer.
    init(what: String, where loc: String, severity: Severity, id: String? = nil, when: Date? = nil, type: AlertType? = nil, source: String? = nil, applicationsOrServices: [String]? = nil, URLs: [AlertURL]? = nil, details: [Detail]? = nil, emailMessageToSend: EmailMessage? = nil, smsMessageToSend: String? = nil, voiceMessageToSend: String? = nil) {
        
        self.what = what
        self.`where` = loc
        self.severity = severity
        self.id = id
        self.when = when
        self.type = type
        self.source = source
        self.applicationsOrServices = applicationsOrServices
        self.URLs = URLs
        self.details = details
        self.emailMessageToSend = emailMessageToSend
        self.smsMessageToSend = smsMessageToSend
        self.voiceMessageToSend = voiceMessageToSend
    }
    
    // JSON initializer.
    init?(data: Data) {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any] {
            // Mandatory properties.
            if let what = dictionary["What"] as? String {
                self.what = what
            } else {
                return nil
            }
            if let `where` = dictionary["Where"] as? String {
                self.`where` = `where`
            } else {
                return nil
            }
            if let severity = dictionary["Severity"] as? String, let sevValue = getSeverity(from: severity) {
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
            if let when = dictionary["When"] as? String {
                let dateFormatter = DateFormatter()
                self.when = dateFormatter.date(from: when)
            } else if let when = dictionary["When"] as? Int {
                self.when = Date(timeIntervalSince1970: Double(when) as TimeInterval)
            }
            if let type = dictionary["Type"] as? String, let typeValue = AlertType(rawValue: type) {
                self.type = typeValue
            }
            if let source = dictionary["Source"] as? String {
                self.source = source
            }
            if let apps = dictionary["ApplicationsOrServices"] as? [String] {
                self.applicationsOrServices = apps
            }
            if let URLs = dictionary["URLs"] as? [[String: String]] {
                var URLarray = [AlertURL]()
                for alertURL in URLs {
                    if let description = alertURL["Description"], let URLvalue = alertURL["URL"] {
                        URLarray.append(AlertURL(description: description, URL: URLvalue))
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
            if let sms = dictionary["SMSMessageToSend"] as? String {
                self.smsMessageToSend = sms
            }
            if let voice = dictionary["VoiceMessageToSend"] as? String {
                self.voiceMessageToSend = voice
            }
            if let notificationState = dictionary["NotificationState"] as? String, let notValue = NotificationState(rawValue: notificationState) {
                self.notificationState = notValue
            }
            if let firstOccurrence = dictionary["FirstOccurrence"] as? Int {
                self.firstOccurrence = Date(timeIntervalSince1970: Double(firstOccurrence) as TimeInterval)
            }
            if let lastNotified = dictionary["LastNotified"] as? Int {
                self.lastNotified = Date(timeIntervalSince1970: Double(lastNotified) as TimeInterval)
            }
            if let internalTime = dictionary["InternalTime"] as? Int {
                self.internalTime = Date(timeIntervalSince1970: Double(internalTime) as TimeInterval)
            }
            if let expired = dictionary["Expired"] as? Bool {
                self.expired = expired
            }
        } else {
            self.shortId = "Error"
            self.what = "Error"
            self.`where` = "Error"
            self.severity = .Fatal
            self.notificationState = .Escalated
            self.firstOccurrence = Date()
            self.internalTime = Date()
        }
    }
    
    // Alternate option 1: string date.
    convenience init?(what: String, where loc: String, severity: Severity, id: String? = nil, when: String, type: AlertType? = nil, source: String? = nil, applicationsOrServices: [String]? = nil, URLs: [AlertURL]? = nil, details: [Detail]? = nil, emailMessageToSend: EmailMessage? = nil, smsMessageToSend: String? = nil, voiceMessageToSend: String? = nil) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date: Date = dateFormatter.date(from: when) else {
            return nil
        }
        self.init(what: what, where: loc, severity: severity, id: id, when: date, type: type, source: source, applicationsOrServices: applicationsOrServices, URLs: URLs, details: details, emailMessageToSend: emailMessageToSend, smsMessageToSend: smsMessageToSend, voiceMessageToSend: voiceMessageToSend)
    }
    
    // Alternate option 2: integer date.
    convenience init?(what: String, where loc: String, severity: Severity, id: String? = nil, when: Int, type: AlertType? = nil, source: String? = nil, applicationsOrServices: [String]? = nil, URLs: [AlertURL]? = nil, details: [Detail]? = nil, emailMessageToSend: EmailMessage? = nil, smsMessageToSend: String? = nil, voiceMessageToSend: String? = nil) {
        
        let date: Date = Date(timeIntervalSince1970: Double(when) as TimeInterval)
        self.init(what: what, where: loc, severity: severity, id: id, when: date, type: type, source: source, applicationsOrServices: applicationsOrServices, URLs: URLs, details: details, emailMessageToSend: emailMessageToSend, smsMessageToSend: smsMessageToSend, voiceMessageToSend: voiceMessageToSend)
    }
    
    /*
     * Class functions.
     */
    
    // Delete an alert.
    class func delete(id: String) -> (statusCode: Int, message: String) {
        return (204, "Successful request")
    }
    
    // Get an alert.
    class func get(id: String) -> Alert? {
        return nil
    }
}
