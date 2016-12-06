//
//  Alert.swift
//  AlertNotifications
//
//  Created by Jim Avery on 11/21/16.
//
//

import Foundation

import LoggerAPI

class Alert {
    /*
     * Instance variables.
     */
    
    // Required variables.
    let what: String
    let `where`: String
    let severity: Severity
    
    // Optional variables.
    private(set) var id: String?
    private(set) var shortId: String?
    private(set) var when: Date?
    private(set) var type: AlertType?
    private(set) var source: String?
    private(set) var applicationsOrServices: [String]?
    private(set) var URLs: [AlertURL]?
    private(set) var details: [Detail]?
    private(set) var emailMessageToSend: EmailMessage?
    private(set) var smsMessageToSend: String?
    private(set) var voiceMessageToSend: String?
    private(set) var notificationState: NotificationState?
    private(set) var firstOccurrence: Date?
    private(set) var lastNotified: Date?
    private(set) var internalTime: Date?
    private(set) var expired: Bool?
    
    /*
     * Builder.
     */
    class Builder {
        var _what: String?
        var _where: String?
        var _severity: Severity?
        var _id: String?
        var _when: Date?
        var _type: AlertType?
        var _source: String?
        var _applicationsOrServices: [String]?
        var _URLs: [AlertURL]?
        var _details: [Detail]?
        var _emailMessageToSend: EmailMessage?
        var _smsMessageToSend: String?
        var _voiceMessageToSend: String?
        
        init() {
            
        }
        
        init(from alert: Alert) {
            self._what = alert.what
            self._where = alert.`where`
            self._severity = alert.severity
            self._id = alert.id
            self._when = alert.when
            self._type = alert.type
            self._source = alert.source
            self._applicationsOrServices = alert.applicationsOrServices
            self._URLs = alert.URLs
            self._details = alert.details
            self._emailMessageToSend = alert.emailMessageToSend
            self._smsMessageToSend = alert.smsMessageToSend
            self._voiceMessageToSend = alert.voiceMessageToSend
        }
        
        func what(_ _what: String) -> Builder {
            self._what = _what
            return self
        }
        
        func `where`(_ _where: String) -> Builder {
            self._where = _where
            return self
        }
        
        func severity(_ _severity: Severity) -> Builder {
            self._severity = _severity
            return self
        }
        
        func id(_ _id: String) -> Builder {
            self._id = _id
            return self
        }
        
        func when(_ _when: Date) -> Builder {
            self._when = _when
            return self
        }
        
        func when(_ _when: String) throws -> Builder {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let date: Date = dateFormatter.date(from: _when) else {
                throw AlertNotificationError.AlertError("Invalid String format for variable \"when\". Correct format is yyyy-MM-dd HH:mm:ss")
            }
            return self.when(date)
        }
        
        func when(_ _when: Int) -> Builder {
            let date: Date = Date(timeIntervalSince1970: (Double(_when)/1000.0) as TimeInterval)
            return self.when(date)
        }
        
        func type(_ _type: AlertType) -> Builder {
            self._type = _type
            return self
        }
        
        func source(_ _source: String) -> Builder {
            self._source = _source
            return self
        }
        
        func applicationsOrServices(_ _apps: [String]) -> Builder {
            self._applicationsOrServices = _apps
            return self
        }
        
        func URLs(_ _URLs: [AlertURL]) -> Builder {
            self._URLs = _URLs
            return self
        }
        
        func details(_ _details: [Detail]) -> Builder {
            self._details = _details
            return self
        }
        
        func emailMessageToSend(_ _email: EmailMessage) -> Builder {
            self._emailMessageToSend = _email
            return self
        }
        
        func smsMessageToSend(_ _sms: String) -> Builder {
            self._smsMessageToSend = _sms
            return self
        }
        
        func voiceMessageToSend(_ _voice: String) -> Builder {
            self._voiceMessageToSend = _voice
            return self
        }
        
        func build() throws -> Alert {
            guard let what = self._what, let `where` = self._where, let severity = self._severity else {
                throw AlertNotificationError.AlertError("Cannot build Alert object without values for variables \"what\", \"where\" and \"severity\".")
            }
            return Alert(what: what, where: `where`, severity: severity, id: self._id, when: self._when, type: self._type, source: self._source, applicationsOrServices: self._applicationsOrServices, URLs: self._URLs, details: self._details, emailMessageToSend: self._emailMessageToSend, smsMessageToSend: self._smsMessageToSend, voiceMessageToSend: self._voiceMessageToSend)
        }
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
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.when = dateFormatter.date(from: when)
            } else if let when = dictionary["When"] as? Int {
                self.when = Date(timeIntervalSince1970: (Double(when)/1000.0) as TimeInterval)
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
    func postBody() throws -> Data? {
        var postDict: Dictionary<String, Any> = Dictionary<String, Any>()
        postDict["What"] = self.what
        postDict["Where"] = self.`where`
        postDict["Severity"] = self.severity.rawValue
        if let alertId = self.id {
            postDict["Identifier"] = alertId
        }
        if let shortId = self.shortId {
            postDict["ShortId"] = shortId
        }
        if let alertWhen = self.when {
            postDict["When"] = Int(alertWhen.timeIntervalSince1970 * 1000.0)
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
        if let notState = self.notificationState {
            postDict["NotificationState"] = notState.rawValue
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
    
    // Create a POST request with this alert.
    func post(usingCredentials credentials: ServerCredentials, callback: ((Alert?, Error?) -> Void)? = nil) throws {
        guard let bluemixRequest = BluemixRequest(type: .Alert, usingCredentials: credentials) else {
            throw AlertNotificationError.AlertError("Invalid URL provided.")
        }
        let errors = [208: "This error has already been reported.", 400: "The service reported an invalid request.", 401: "Authorization is invalid.", 415: "Invalid media type for alert."]
        let bluemixCallback = Alert.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.postAlert(self, callback: bluemixCallback)
    }
    
    /*
     * Class functions and properties.
     */
    
    // Create a callback function for when we are expecting an Alert object in response.
    class func alertCallbackBuilder(statusResponses: [Int: String], withFinalCallback callback: ((Alert?, Error?) -> Void)? = nil) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return { (data: Data?, response: URLResponse?, error: Swift.Error?) in
            // Possible error #1: no data received.
            if data == nil {
                if callback != nil {
                    if error == nil {
                        callback!(nil, AlertNotificationError.HTTPError("Payload from server is empty."))
                    } else {
                        callback!(nil, error)
                    }
                }
                Log.error("Payload from server is empty.")
                if error != nil {
                    Log.error(error!.localizedDescription)
                }
                return
            }
            
            // Possible error #2: error received.
            if error != nil {
                if callback != nil {
                    callback!(nil, error)
                }
                Log.error(error!.localizedDescription)
                return
            }
            
            // Possible error #3: bad response code from the server.
            if let httpResponse = response as? HTTPURLResponse, let errMessage = statusResponses[httpResponse.statusCode] {
                if callback != nil {
                    callback!(nil, AlertNotificationError.BluemixError(errMessage))
                }
                Log.error(errMessage)
                return
            }
            
            // Possible error #4: malformed response data.
            guard let alertResponse = Alert(data: data!) else {
                if callback != nil {
                    callback!(nil, AlertNotificationError.HTTPError("Malformed response from server."))
                }
                Log.error("Malformed response from server.")
                return
            }
            
            // Finally, perform the callback on the data.
            if callback != nil {
                callback!(alertResponse, nil)
            }
        }
    }
    
    // Delete an alert.
    class func delete(shortId id: String, usingCredentials credentials: ServerCredentials, callback: ((Int?, Error?) -> Void)? = nil) throws {
        guard let bluemixRequest = BluemixRequest(type: .Alert, usingCredentials: credentials) else {
            throw AlertNotificationError.AlertError("Invalid URL provided.")
        }
        try bluemixRequest.deleteAlert(shortId: id) { (data, response, error) in
            // Possible error #1: error received.
            if error != nil {
                if callback != nil {
                    callback!(nil, error)
                }
                Log.error(error!.localizedDescription)
                return
            }
            
            // Possible error #2: bad response code from the server.
            guard let httpResponse = response as? HTTPURLResponse else {
                if callback != nil {
                    callback!(nil, AlertNotificationError.HTTPError("Could not parse the HTTP response from the server."))
                }
                Log.error("Could not parse the HTTP response from the server.")
                return
            }
            var httpError: String? = nil
            switch httpResponse.statusCode {
            case 401:
                httpError = "Authorization is invalid."
            case 404:
                httpError = "The alert could not be found."
            case 500:
                httpError = "There was an error archiving the alert."
            default:
                break
            }
            if httpError != nil {
                if callback != nil {
                    callback!(httpResponse.statusCode, AlertNotificationError.HTTPError(httpError!))
                }
                Log.error(httpError!)
                return
            }
            
            // Finally, perform the callback on the response.
            if callback != nil {
                callback!(httpResponse.statusCode, nil)
            }
        }
    }
    
    // Get an alert.
    class func get(shortId id: String, usingCredentials credentials: ServerCredentials, callback: ((Alert?, Error?) -> Void)? = nil) throws {
        guard let bluemixRequest = BluemixRequest(type: .Alert, usingCredentials: credentials) else {
            throw AlertNotificationError.AlertError("Invalid URL provided.")
        }
        let errors = [401: "Authorization is invalid.", 404: "An alert matching this short ID could not be found."]
        let bluemixCallback = Alert.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getAlert(shortId: id, callback: bluemixCallback)
    }
}
