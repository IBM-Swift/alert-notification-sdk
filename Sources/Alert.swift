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
            Log.error("Failed to convert Alert object to JSON.")
        }
        
        return nil
    }
    
    // Create a POST request with this alert.
    func post(to alertURL: URL? = nil, user: String? = nil, password: String? = nil, callback: ((Alert?, Error?) -> Void)? = nil) throws -> URLSessionDataTask? {
        // Either use the URL passed in as a parameter, or try to use the one pre-supplied in ServerCredentials.
        var alertServerURL: URL? = alertURL
        if alertURL == nil {
            guard let baseURL = ServerCredentials.host else {
                throw AlertNotificationError.AlertError("No URL provided.")
            }
            alertServerURL = URL(string: "\(baseURL)/alerts/v1")
        }
        
        let session: URLSession = URLSession.shared
        var request: URLRequest = URLRequest(url: alertServerURL!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // If a user and password were not both passed into the function, try to use whatever is stored.
        if user != nil && password != nil {
            let rawAuth = "\(user):\(password)"
            let encodedAuth = rawAuth.data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(encodedAuth)", forHTTPHeaderField: "Authorization")
        } else if let storedAuthString = ServerCredentials.authString {
            request.setValue("Basic \(storedAuthString)", forHTTPHeaderField: "Authorization")
        } else {
            throw AlertNotificationError.AlertError("No authentication credentials provided.")
        }
        
        guard let alertData = self.postBody() else {
            throw AlertNotificationError.AlertError("Invalid data in alert object.")
        }
        request.httpBody = alertData
        let postTask = session.dataTask(with: request) { (data, response, error) in
            // Possible error #1: no data received.
            if data == nil {
                let retError = error == nil ? AlertNotificationError.AlertError("Payload from server is empty.") : error
                if callback != nil {
                    callback!(nil, retError)
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
            if let httpResponse = response as? HTTPURLResponse {
                var httpError: String? = nil
                switch httpResponse.statusCode {
                case 208:
                    httpError = "This error has already been reported."
                case 400:
                    httpError = "The server reported an invalid request."
                case 415:
                    httpError = "Invalid media type for alert."
                default:
                    break
                }
                if httpError != nil {
                    if callback != nil {
                        callback!(nil, AlertNotificationError.AlertError(httpError!))
                    }
                    Log.error(httpError!)
                    return
                }
            }
            
            // Possible error #4: malformed response data.
            guard let alertResponse = Alert(data: data!) else {
                if callback != nil {
                    callback!(nil, AlertNotificationError.AlertError("Malformed response from server."))
                }
                Log.error("Malformed response from server.")
                return
            }
            
            // Finally, perform the callback on the data.
            if callback != nil {
                callback!(alertResponse, nil)
            }
        }
        
        postTask.resume()
        return postTask
    }
    
    // Same, but handle the case of being passed a string URL.
    func post(to alertURL: String, user: String? = nil, password: String? = nil, callback: ((Alert?, Error?) -> Void)? = nil) throws -> URLSessionDataTask? {
        return try self.post(to: URL(string: "\(alertURL)/alerts/v1"), callback: callback)
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
            return nil
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
     * Class functions and properties.
     */
    
    // Create a URLRequest with basic authentication.
    class func createRequest(withMethod method: HTTPMethod, withId id: String? = nil, to alertURL: URL? = nil, user: String? = nil, password: String? = nil) throws -> URLRequest {
        // Either use the URL passed in as a parameter, or try to use the one pre-supplied in ServerCredentials.
        var alertServerURL: URL? = alertURL
        if alertURL == nil {
            guard let baseURL = ServerCredentials.host else {
                throw AlertNotificationError.AlertError("No URL provided.")
            }
            if method == .Post {
                alertServerURL = URL(string: "\(baseURL)/alerts/v1")
            } else if id != nil {
                alertServerURL = URL(string: "\(baseURL)/alerts/v1/\(id)")
            } else {
                throw AlertNotificationError.AlertError("No alert ID was provided for GET or DELETE request.")
            }
        }
        
        var request: URLRequest = URLRequest(url: alertServerURL!)
        
        // If a user and password were not both passed into the function, try to use whatever is stored.
        if user != nil && password != nil {
            let rawAuth = "\(user):\(password)"
            let encodedAuth = rawAuth.data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(encodedAuth)", forHTTPHeaderField: "Authorization")
        } else if let storedAuthString = ServerCredentials.authString {
            request.setValue("Basic \(storedAuthString)", forHTTPHeaderField: "Authorization")
        } else {
            throw AlertNotificationError.AlertError("No authentication credentials provided.")
        }
        
        return request
    }
    
    // Delete an alert.
    class func delete(id: String, to alertURL: URL? = nil, user: String? = nil, password: String? = nil, callback: ((Int?, Error?) -> Void)? = nil) throws -> URLSessionDataTask {
        // Either use the URL passed in as a parameter, or try to use the one pre-supplied in ServerCredentials.
        var alertServerURL: URL? = alertURL
        if alertURL == nil {
            guard let baseURL = ServerCredentials.host else {
                throw AlertNotificationError.AlertError("No URL provided.")
            }
            alertServerURL = URL(string: "\(baseURL)/alerts/v1/\(id)")
        }
        
        let session: URLSession = URLSession.shared
        var request: URLRequest = URLRequest(url: alertServerURL!)
        request.httpMethod = "DELETE"
        
        // If a user and password were not both passed into the function, try to use whatever is stored.
        if user != nil && password != nil {
            let rawAuth = "\(user):\(password)"
            let encodedAuth = rawAuth.data(using: .utf8)!.base64EncodedString()
            request.setValue("Basic \(encodedAuth)", forHTTPHeaderField: "Authorization")
        } else if let storedAuthString = ServerCredentials.authString {
            request.setValue("Basic \(storedAuthString)", forHTTPHeaderField: "Authorization")
        } else {
            throw AlertNotificationError.AlertError("No authentication credentials provided.")
        }
        
        let deleteTask = session.dataTask(with: request) { (data, response, error) in
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
                    callback!(nil, AlertNotificationError.AlertError("Could not parse the HTTP response from the server."))
                }
                Log.error("Could not parse the HTTP response from the server.")
                return
            }
            var httpError: String? = nil
            switch httpResponse.statusCode {
            case 404:
                httpError = "The alert could not be found."
            case 500:
                httpError = "There was an error archiving the alert."
            default:
                break
            }
            if httpError != nil {
                if callback != nil {
                    callback!(httpResponse.statusCode, AlertNotificationError.AlertError(httpError!))
                }
                Log.error(httpError!)
                return
            }
            
            // Finally, perform the callback on the response.
            if callback != nil {
                callback!(httpResponse.statusCode, nil)
            }
        }
        
        deleteTask.resume()
        return deleteTask
    }
    
    // Delete, with a string URL.
    class func delete(id: String, to alertURL: String, user: String? = nil, password: String? = nil, callback: ((Int?, Error?) -> Void)? = nil) throws -> URLSessionDataTask {
        return try Alert.delete(id: id, to: URL(string: "\(alertURL)/alerts/v1/\(id)"), user: user, password: password, callback: callback)
    }
    
    // Get an alert.
    class func get(id: String) -> Alert? {
        return nil
    }
}
