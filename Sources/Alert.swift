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
    let summary: String
    let location: String
    let severity: Severity
    
    // Optional variables.
    private(set) var id: String?
    private(set) var shortId: String?
    private(set) var date: Date?
    private(set) var status: AlertStatus?
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
        var summary: String?
        var location: String?
        var severity: Severity?
        var id: String?
        var date: Date?
        var status: AlertStatus?
        var source: String?
        var applicationsOrServices: [String]?
        var URLs: [AlertURL]?
        var details: [Detail]?
        var emailMessageToSend: EmailMessage?
        var smsMessageToSend: String?
        var voiceMessageToSend: String?
        
        init() {
            
        }
        
        init(from alert: Alert) {
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
            self.smsMessageToSend = alert.smsMessageToSend
            self.voiceMessageToSend = alert.voiceMessageToSend
        }
        
        func setSummary(_ summary: String) -> Builder {
            self.summary = summary
            return self
        }
        
        func setLocation(_ location: String) -> Builder {
            self.location = location
            return self
        }
        
        func setSeverity(_ severity: Severity) -> Builder {
            self.severity = severity
            return self
        }
        
        func setID(_ id: String) -> Builder {
            self.id = id
            return self
        }
        
        func setDate(_ date: Date) -> Builder {
            self.date = date
            return self
        }
        
        func setDate(fromString date: String) throws -> Builder {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            guard let date: Date = dateFormatter.date(from: date) else {
                throw AlertNotificationError.AlertError("Invalid String format for variable \"date\". Correct format is yyyy-MM-dd HH:mm:ss")
            }
            return self.setDate(date)
        }
        
        func setDate(fromIntInMilliseconds date: Int) -> Builder {
            let date: Date = Date(timeIntervalSince1970: (Double(date)/1000.0) as TimeInterval)
            return self.setDate(date)
        }
        
        func setStatus(_ status: AlertStatus) -> Builder {
            self.status = status
            return self
        }
        
        func setSource(_ source: String) -> Builder {
            self.source = source
            return self
        }
        
        func setApplicationsOrServices(_ apps: [String]) -> Builder {
            self.applicationsOrServices = apps
            return self
        }
        
        func setURLs(_ URLs: [AlertURL]) -> Builder {
            self.URLs = URLs
            return self
        }
        
        func setDetails(_ details: [Detail]) -> Builder {
            self.details = details
            return self
        }
        
        func setEmailMessageToSend(_ email: EmailMessage) -> Builder {
            self.emailMessageToSend = email
            return self
        }
        
        func setSMSMessageToSend(_ sms: String) -> Builder {
            self.smsMessageToSend = sms
            return self
        }
        
        func setVoiceMessageToSend(_ voice: String) -> Builder {
            self.voiceMessageToSend = voice
            return self
        }
        
        func build() throws -> Alert {
            guard let summary = self.summary, let location = self.location, let severity = self.severity else {
                throw AlertNotificationError.AlertError("Cannot build Alert object without values for variables \"summary\", \"location\" and \"severity\".")
            }
            return Alert(summary: summary, location: location, severity: severity, id: self.id, date: self.date, status: self.status, source: self.source, applicationsOrServices: self.applicationsOrServices, URLs: self.URLs, details: self.details, emailMessageToSend: self.emailMessageToSend, smsMessageToSend: self.smsMessageToSend, voiceMessageToSend: self.voiceMessageToSend)
        }
    }
    
    /*
     * Initializers.
     */
    
    // Base initializer.
    private init(summary: String, location: String, severity: Severity, id: String? = nil, date: Date? = nil, status: AlertStatus? = nil, source: String? = nil, applicationsOrServices: [String]? = nil, URLs: [AlertURL]? = nil, details: [Detail]? = nil, emailMessageToSend: EmailMessage? = nil, smsMessageToSend: String? = nil, voiceMessageToSend: String? = nil) {
        
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
        self.smsMessageToSend = smsMessageToSend
        self.voiceMessageToSend = voiceMessageToSend
    }
    
    // JSON initializer.
    internal init?(data: Data) {
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
            if let date = dictionary["When"] as? String {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.date = dateFormatter.date(from: date)
            } else if let date = dictionary["When"] as? Int {
                self.date = Date(timeIntervalSince1970: (Double(date)/1000.0) as TimeInterval)
            }
            if let status = dictionary["Type"] as? String, let statusValue = AlertStatus(rawValue: status) {
                self.status = statusValue
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
            postDict["Type"] = alertStatus.rawValue
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
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
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
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
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
            var bluemixError: String? = nil
            switch httpResponse.statusCode {
            case 401:
                bluemixError = "Authorization is invalid."
            case 404:
                bluemixError = "The alert could not be found."
            case 500:
                bluemixError = "There was an error archiving the alert."
            default:
                break
            }
            if bluemixError != nil {
                if callback != nil {
                    callback!(httpResponse.statusCode, AlertNotificationError.BluemixError(bluemixError!))
                }
                Log.error(bluemixError!)
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
        guard let bluemixRequest = BluemixRequest(usingCredentials: credentials) else {
            throw AlertNotificationError.AlertError("Invalid URL provided.")
        }
        let errors = [401: "Authorization is invalid.", 404: "An alert matching this short ID could not be found."]
        let bluemixCallback = Alert.alertCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getAlert(shortId: id, callback: bluemixCallback)
    }
}
