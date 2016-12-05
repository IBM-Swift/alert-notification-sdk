//
//  BluemixRequest.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/5/16.
//
//

import Foundation

import KituraNet

import LoggerAPI

class BluemixRequest {
    let USE_KITURA_NET: Bool = false
    
    /*
     * Instance veriables and methods.
     */
    
    // Common variables.
    let type: RequestType
    let baseURL: URL
    let credentials: ServerCredentials
    
    // URLSession variables.
    var sessionRequest: URLRequest?
    
    // KituraNet variables.
    
    // Initializer.
    init?(type: RequestType, usingCredentials credentials: ServerCredentials) {
        self.type = type
        self.credentials = credentials
        
        guard let baseURL = URL(string: "\(credentials.url)/\(type.rawValue.lowercased())s/v1/") else {
            Log.error("Invalid URL provided.")
            return nil
        }
        self.baseURL = baseURL
    }
    
    // Submit KituraNet request.
    
    // Submit URLSession request.
    func sendRequest(req: URLRequest, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) {
        let session: URLSession = createSession()
        let reqTask = session.dataTask(with: req) { (data, response, error) in
            if callback != nil {
                callback!(data, response, error)
            }
        }
        reqTask.resume()
        session.finishTasksAndInvalidate()
    }
    
    /*
     * Alert requests.
     */
    
    func postAlert(_ alert: Alert, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            
        } else {
            var request: URLRequest = URLRequest(url: self.baseURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            let alertBody = try alert.postBody()
            request.httpBody = alertBody
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func getAlert(shortId id: String, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            
        } else {
            guard let fullUrl: URL = URL(string: id, relativeTo: self.baseURL) else {
                throw AlertNotificationError.AlertError("Invalid alert ID provided to GET request.")
            }
            var request: URLRequest = URLRequest(url: fullUrl)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func deleteAlert(shortId id: String, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            
        } else {
            guard let fullUrl: URL = URL(string: id, relativeTo: self.baseURL) else {
                throw AlertNotificationError.AlertError("Invalid alert ID provided to DELETE request.")
            }
            var request: URLRequest = URLRequest(url: fullUrl)
            request.httpMethod = "DELETE"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    /*
     * Message requests.
     */
    
    func postMessage(message: Message, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            
        } else {
            
        }
    }
    
    func getMessage(shortId id: String, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        
    }
}
